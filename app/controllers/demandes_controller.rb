class DemandesController < ApplicationController
  def show
    @dossier = Dossier.find(params[:dossier_id])
    @evenements_vie = EvenementVie.for_admi_facile
  end

  def update
    dossier = Dossier.find(params[:dossier_id])
    if !dossier.formulaire.nil?
      raise "La modification du formulaire n'est pas possible"
    end
    dossier.update_attributes(formulaire_id: params[:formulaire])
    dossier.build_default_pieces_jointes
    redirect_to url_for(controller: :carte, action: :show, dossier_id: params[:dossier_id])
  end

end
