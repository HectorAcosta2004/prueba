import { serve } from "https://deno.land/std@0.131.0/http/server.ts"
import { create } from "https://deno.land/x/djwt@v2.4/mod.ts"

serve(async (req) => {
  try {
    const { record } = await req.json() // Datos de la fila insertada en la DB

    // 1. Configurar Credenciales desde variables de entorno
    const projectID = Deno.env.get('FIREBASE_PROJECT_ID')
    const clientEmail = Deno.env.get('FIREBASE_CLIENT_EMAIL')
    const privateKey = Deno.env.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n')

    // 2. Generar Token de Acceso para Google Auth (OAuth2)
    const jwt = await create({ alg: "RS256", typ: "JWT" }, {
      iss: clientEmail,
      scope: "https://www.googleapis.com/auth/cloud-platform",
      aud: "https://oauth2.googleapis.com/token",
      exp: Math.floor(Date.now() / 1000) + 3600,
      iat: Math.floor(Date.now() / 1000),
    }, privateKey!)

    const res = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: jwt,
      }),
    })
    const { access_token } = await res.json()

    // 3. Enviar la notificación a Firebase
    // Nota: 'record.fcm_token' asume que tu tabla tiene el token del destinatario
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectID}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${access_token}`,
        },
        body: JSON.stringify({
          message: {
            token: record.fcm_token, // Aquí va el token del celular del usuario
            notification: {
              title: "¡Nuevo mensaje!",
              body: record.content || "Tienes una nueva actualización",
            },
          },
        }),
      }
    )

    return new Response(JSON.stringify({ ok: true }), { status: 200 })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
