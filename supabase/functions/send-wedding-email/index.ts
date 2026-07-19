import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface EmailRequest {
  type: 'rsvp_confirmation' | 'reminder' | 'custom'
  to: string
  guestName: string
  attending?: boolean
  daysUntilWedding?: number
  subject?: string
  customHtml?: string
}

function buildRsvpConfirmationHtml(guestName: string, attending: boolean): string {
  const status = attending ? 'confirmée' : 'déclinée'
  const statusColor = attending ? '#c0392b' : '#7f8c8d'
  const statusWord = attending ? 'confirmée' : 'déclinée'

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background-color:#f5f0eb;font-family:Georgia,'Times New Roman',serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f0eb;padding:40px 20px;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
        <!-- Header -->
        <tr>
          <td style="background-color:#c07a5e;padding:30px 40px;text-align:center;">
            <span style="font-size:24px;">💍</span>
            <h1 style="color:#ffffff;font-size:20px;margin:10px 0 0 0;font-weight:400;">Confirmation de votre RSVP</h1>
          </td>
        </tr>
        <!-- Body -->
        <tr>
          <td style="padding:30px 40px;color:#333333;font-size:15px;line-height:1.7;">
            <p>Bonjour <strong>${guestName}</strong>,</p>
            <p>Merci de votre réponse ! Votre présence est <span style="color:${statusColor};font-weight:bold;">${statusWord}</span> pour le mariage de Sonia &amp; Aimé.</p>
            <p><strong>Date :</strong> 28 novembre 2026<br>
            <strong>Heure :</strong> 18h00</p>
            <p>À bientôt !</p>
          </td>
        </tr>
        <!-- Footer -->
        <tr>
          <td style="padding:20px 40px;text-align:center;border-top:1px solid #eee;color:#aaa;font-size:12px;">
            Mariage Sonia &amp; Aimé Francis • 28 novembre 2026
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`
}

function buildReminderHtml(guestName: string, days: number): string {
  const dayWord = days === 1 ? 'jour' : 'jours'

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background-color:#f5f0eb;font-family:Georgia,'Times New Roman',serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f5f0eb;padding:40px 20px;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:8px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
        <!-- Header -->
        <tr>
          <td style="background-color:#c07a5e;padding:30px 40px;text-align:center;">
            <span style="font-size:24px;">💍</span>
            <h1 style="color:#ffffff;font-size:20px;margin:10px 0 0 0;font-weight:400;">Le mariage dans ${days} ${dayWord} !</h1>
          </td>
        </tr>
        <!-- Body -->
        <tr>
          <td style="padding:30px 40px;color:#333333;font-size:15px;line-height:1.7;">
            <p>Bonjour <strong>${guestName}</strong>,</p>
            <p>Le grand jour approche ! Nous vous rappelons que le mariage de Sonia &amp; Aimé aura lieu dans <strong>${days} ${dayWord}</strong>.</p>
            <p><strong>Date :</strong> 28 novembre 2026<br>
            <strong>Heure :</strong> 18h00</p>
            <p>À très bientôt !</p>
          </td>
        </tr>
        <!-- Footer -->
        <tr>
          <td style="padding:20px 40px;text-align:center;border-top:1px solid #eee;color:#aaa;font-size:12px;">
            Mariage Sonia &amp; Aimé Francis • 28 novembre 2026
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const resendApiKey = Deno.env.get('RESEND_API_KEY')
    if (!resendApiKey) {
      return new Response(
        JSON.stringify({ error: 'RESEND_API_KEY not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const body: EmailRequest = await req.json()
    const { type, to, guestName, attending, daysUntilWedding, subject, customHtml } = body

    if (!to || !guestName) {
      return new Response(
        JSON.stringify({ error: 'Missing to or guestName' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    let html: string
    let emailSubject: string

    switch (type) {
      case 'rsvp_confirmation':
        html = buildRsvpConfirmationHtml(guestName, attending ?? true)
        emailSubject = subject || 'Confirmation de votre RSVP - Mariage Sonia & Aimé'
        break
      case 'reminder':
        html = buildReminderHtml(guestName, daysUntilWedding ?? 7)
        emailSubject = subject || `Rappel - Mariage dans ${daysUntilWedding ?? 7} jours`
        break
      case 'custom':
        if (!customHtml) {
          return new Response(
            JSON.stringify({ error: 'Missing customHtml for custom email type' }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }
        html = customHtml
        emailSubject = subject || 'Message du mariage Sonia & Aimé'
        break
      default:
        return new Response(
          JSON.stringify({ error: `Unknown email type: ${type}` }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }

    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Mariage Sonia & Aimé <onboarding@resend.dev>',
        to: [to],
        subject: emailSubject,
        html: html,
      }),
    })

    const resendData = await resendResponse.json()

    if (!resendResponse.ok) {
      return new Response(
        JSON.stringify({ error: 'Resend API error', details: resendData }),
        { status: resendResponse.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ success: true, id: resendData.id }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
