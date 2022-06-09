class ConditionsController < ApplicationController
  include Logic

  def show
    @procedure = Procedure.find(params[:id])
  end

  def update
    tdc = TypeDeChamp.find(params[:type_de_champ][:id])
    condition = ConditionForm.new(condition_params).to_condition
    tdc.update(condition: condition)
    redirect_to condition_path(params[:id])
  end

  def add_row
    tdc = TypeDeChamp.find(params[:type_de_champ][:id])
    condition = tdc.condition

    empty_condition = empty_operator(empty, empty)

    new_condition = if condition.nil?
      empty_condition
    elsif [And, Or].include?(condition.class)
      condition.class.new(condition.operands << empty_condition)
    else
      Logic::And.new([condition, empty_condition])
    end

    tdc.update(condition: new_condition)

    redirect_to condition_path(params[:id])
  end

  def delete_row
    tdc = TypeDeChamp.find(params[:type_de_champ][:id])
    condition = ConditionForm.new(condition_params).delete_row(row_index).to_condition
    tdc.update(condition: condition)
    redirect_to condition_path(params[:id])
  end

  def delete
    tdc = TypeDeChamp.find(params[:type_de_champ][:id])
    tdc.update(condition: nil)
    redirect_to condition_path(params[:id])
  end

  def change_champ
    tdc = TypeDeChamp.find(params[:type_de_champ][:id])
    condition = ConditionForm.new(condition_params).change_champ(row_index).to_condition
    tdc.update(condition: condition)
    redirect_to condition_path(params[:id])
  end

  private

  def condition_params
    params
      .require(:type_de_champ)
      .require(:condition_form)
      .permit(:top_operator_name, rows: [:targeted_champ, :operator_name, :value])
  end

  def row_index
    params[:row_index].to_i
  end
end
