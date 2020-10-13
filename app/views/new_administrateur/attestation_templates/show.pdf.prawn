require 'prawn/measurement_extensions'
require 'prawn/qrcode'


#----- A4 page size
page_size = 'A4'
#page_height = 842
page_width = 595

#----- margins
body_width = 400
top_margin = 50
bottom_margin = 20

right_margin = (page_width - body_width) / 2
left_margin = right_margin

#----- size of images
max_logo_width = body_width
max_logo_height = 50.mm
max_signature_size = 50.mm
qrcode_size = 35.mm

def normalize_pdf_text(text)
  text&.tr("\t", '  ')
end

title = normalize_pdf_text(@attestation.fetch(:title))
body = normalize_pdf_text(@attestation.fetch(:body))
footer = normalize_pdf_text(@attestation.fetch(:footer))
created_at = @attestation.fetch(:created_at)

logo = @attestation[:logo]
signature = @attestation[:signature]
qrcode = @attestation[:qrcode]
footer_height = qrcode.present? ? qrcode_size + 40 : 30

info = {
  :Title => title,
  :Subject => "Attestation pour un dossier",
  :Creator => "#{APPLICATION_NAME}",
  :Producer => "Prawn",
  :CreationDate => created_at
}

prawn_document(margin: [top_margin, right_margin, bottom_margin, left_margin], page_size: page_size, info: info) do |pdf|
  base = 'lib/prawn/fonts/liberation_serif'
  pdf.font_families.update('liberation serif' => {
    normal: Rails.root.join(base,'LiberationSerif-Regular.ttf'),
    bold: Rails.root.join(base,'LiberationSerif-Bold.ttf'),
    bold_italic: Rails.root.join(base,'LiberationSerif-BoldItalic.ttf'),
    italic: Rails.root.join(base,'LiberationSerif-Italic.ttf')
  })
  pdf.font 'liberation serif'

  grey = '555555'
  black = '000000'

  body_height = pdf.cursor - footer_height

  pdf.bounding_box([0, pdf.cursor], width: body_width, height: body_height) do
    if logo.present?
      logo_content = if logo.is_a?(ActiveStorage::Attached::One)
        logo.download
      else
        logo.rewind && logo.read
      end
      pdf.image StringIO.new(logo_content), fit: [max_logo_width , max_logo_height], position: :center
    end

    pdf.fill_color grey
    pdf.pad_top(40) { pdf.text "le #{l(created_at, format: '%e %B %Y')}", size: 9, align: :right, character_spacing: -0.5 }

    pdf.fill_color black
    pdf.pad_top(40) { pdf.text title, size: 20, inline_format: true }

    pdf.fill_color grey
    pdf.pad_top(30) { pdf.text body, size: 12, character_spacing: -0.2, align: :justify, inline_format: true }

    cpos = pdf.cursor - 40
    if signature.present?
      pdf.pad_top(40) do
        signature_content = if signature.is_a?(ActiveStorage::Attached::One)
          signature.download
        else
          signature.rewind && signature.read
        end
        pdf.image StringIO.new(signature_content), fit: [max_signature_size , max_signature_size], position: :right
      end
    end
  end

  pdf.repeat(:all) do
    margin = 2
    pdf.fill_color grey
    if qrcode.present?
      pdf.move_cursor_to footer_height
      pdf.print_qr_code(qrcode, level: :q, extent: qrcode_size, margin: margin, align: :center)
      pdf.move_down 3
      pdf.text "<u><link href='#{qrcode}'>#{title}</link></u>", :inline_format => true, size: 9, align: :center, color: "0000FF"
    end
    pdf.move_cursor_to 20
    if footer.present?
      # We reduce the size of large footer so they can be drawn in the corresponding area.
      # This is due to a font change, the replacing font is slightly bigger than the previous one
      footer_font_size = footer.length > 170 ? 7 : 8
      pdf.text footer, align: :center, size: footer_font_size
    end
  end
end
