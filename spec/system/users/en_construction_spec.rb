describe "Dossier en_construction" do
  let(:user) { create(:user) }
  let(:procedure) { create(:simple_procedure, :with_piece_justificative, :with_titre_identite) }
  let(:dossier) { create(:dossier, :en_construction, :with_individual, :with_populated_champs, user:, procedure:) }

  let(:tdc) {
    procedure.active_revision.types_de_champ_public.find { _1.type_champ == "piece_justificative" }
  }

  let(:champ) {
    dossier.champs_public.find { _1.type_de_champ_id == tdc.id }
  }

  scenario 'delete a non mandatory piece justificative', js: true do
    visit_dossier(dossier)

    expect(page).not_to have_button("Remplacer")
    click_on "Supprimer le fichier toto.txt"

    expect(page).not_to have_text("toto.txt")
  end

  context "with a mandatory piece justificative" do
    before do
      tdc.update_attribute(:mandatory, true)
    end

    scenario 'remplace a mandatory piece justificative', js: true do
      visit_dossier(dossier)

      click_on "Remplacer le fichier toto.txt"

      input_selector = "#attachment-multiple-empty-#{champ.id}"
      expect(page).to have_selector(input_selector)
      find(input_selector).attach_file(Rails.root.join('spec/fixtures/files/file.pdf'))

      expect(page).to have_text("file.pdf")
      expect(page).not_to have_text("toto.txt")
    end
  end

  context "with a mandatory titre identite" do
    let(:tdc) {
      procedure.active_revision.types_de_champ_public.find { _1.type_champ == "titre_identite" }
    }

    before do
      tdc.update_attribute(:mandatory, true)
    end

    scenario 'remplace a mandatory titre identite', js: true do
      visit_dossier(dossier)

      click_on "Remplacer le fichier toto.png"

      input_selector = ".attachment-input-#{champ.piece_justificative_file.attachments.first.id}"
      expect(page).to have_selector(input_selector)
      find(input_selector).attach_file(Rails.root.join('spec/fixtures/files/file.pdf'))

      expect(page).to have_text("file.pdf")
      expect(page).not_to have_text("toto.png")
    end
  end

  private

  def visit_dossier(dossier)
    visit modifier_dossier_path(dossier)

    expect(page).to have_current_path(new_user_session_path)
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_on 'Se connecter'

    expect(page).to have_current_path(modifier_dossier_path(dossier))
  end
end