table.container style="border-spacing: 0; border-collapse: collapse; padding: 0; vertical-align: top; text-align: inherit; background: #343a40; max-width: 600px; margin: 0 auto; Margin: 0 auto;" max-width="600" valign="top" align="inherit"
  tr.header style="padding: 0; vertical-align: top; text-align: left;" valign="top" align="left"
    td.content style="color: white; word-wrap: break-word; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse; font-size: 16px; vertical-align: top; text-align: left; -webkit-hyphens: auto; font-family: Helvetica, Arial, sans-serif; font-weight: normal; margin: 0; Margin: 0; line-height: 1.3; padding: 16px; background: #ef4b62;" valign="top" align="left" bgcolor="#ef4b62"
      h1.title style="text-align: left; margin-top: 0; font-weight: normal; padding: 0; margin: 0; Margin: 0; font-family: 'Muli', 'Helvetica Neue', Helvetica, Arial, sans-serif; line-height: 1.3; word-wrap: normal; margin-bottom: 10px; Margin-bottom: 10px; font-size: 28px; color: white;"
        = I18n.translate("mailer.open_tournament.title")
      h2.subtitle style="text-align: left; margin-top: 0; font-weight: normal; padding: 0; margin: 0; Margin: 0; font-family: 'Muli', 'Helvetica Neue', Helvetica, Arial, sans-serif; line-height: 1.3; word-wrap: normal; margin-bottom: 10px; Margin-bottom: 10px; font-size: 18px; color: white;"
        = I18n.translate("mailer.open_tournament.subtitle", { league_name: tournament.league!.name })
  tr.section style="padding: 0; vertical-align: top; text-align: left;" valign="top" align="left"
    td.content style="text-align: left; word-wrap: break-word; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse; line-height: 1.3; vertical-align: top; -webkit-hyphens: auto; color: white; font-family: Helvetica, Arial, sans-serif; font-weight: normal; margin: 0; Margin: 0; font-size: 16px; padding: 16px;" valign="top" align="left"
      - content.split("\n").each do |content_paragraph|
        p style="padding: 0; margin: 0; color: white; margin-bottom: 10px; font-weight: normal; Margin: 0; text-align: left; line-height: 1.3; font-size: 16px; Margin-bottom: 10px; font-family: 'Muli', 'Helvetica Neue', Helvetica, Arial, sans-serif;"
          = content_paragraph

      table.button.radius style="border-spacing: 0; border-collapse: collapse; padding: 0; vertical-align: top; text-align: left; width: auto; margin: 0 0 16px 0; Margin: 0 0 16px 0;" valign="top" align="left"
        tr style="padding: 0; vertical-align: top; text-align: left;" valign="top" align="left"
          td style="text-align: left; word-wrap: break-word; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse; padding: 0; vertical-align: top; -webkit-hyphens: auto; color: white; font-family: Helvetica, Arial, sans-serif; font-weight: normal; margin: 0; Margin: 0; line-height: 1.3; font-size: 16px;" valign="top" align="left"
            table
              tr style="padding: 0; vertical-align: top; text-align: left;" valign="top" align="left"
                td style="font-family: Helvetica, Arial, sans-serif; word-wrap: break-word; -moz-hyphens: auto; hyphens: auto; border-collapse: collapse; padding: 0; vertical-align: top; font-size: 16px; line-height: 1.3; -webkit-hyphens: auto; font-weight: normal; margin: 0; Margin: 0; color: #fefefe; text-align: left; border: none; border-radius: 3px; background: #4eb4f9; border-color: #4eb4f9;" valign="top" align="left"
                  == link_to(I18n.translate("mailer.open_tournament.action"), "#{ENV["BASE_URL"]}/leagues/#{tournament.league_id}/tournaments/#{tournament.id}", class: "btn btn-primary", style: "line-height: 1.3; text-align: left; margin: 0; Margin: 0; background-color: #4eb4f9; border-color: #4eb4f9; padding: 8px 16px 8px 16px; text-decoration: none; font-size: 16px; display: inline-block; border: 0 solid #2199e8; border-radius: 3px; font-weight: bold; color: #fefefe; font-family: 'Muli', 'Helvetica Neue', Helvetica, Arial, sans-serif;")
