class TypesDeChamp::ConditionsComponent < ApplicationComponent
  include Logic

  def initialize(condition:, upper_tdcs:, procedure_id:)
    @condition, @upper_tdcs, @procedure_id = condition, upper_tdcs, procedure_id
  end

  private

  def rows
    if [And, Or].include?(@condition.class)
      @condition.operands.map { |c| to_row(c) }
    else
      [to_row(@condition)]
    end
  end

  def to_row(condition)
    [condition.left, condition.class.name, condition.right, condition]
  end

  def logic_conditionnel_button
    if @condition.nil?
      submit_tag('cliquer pour activer', formaction: add_row_condition_path(@procedure_id))
    else
      submit_tag('cliquer pour desactiver', formaction: delete_condition_path(@procedure_id))
    end
  end

  def left_tag(row_number)
    if row_number == 0
      'Afficher si'
    elsif row_number == 1
      select_tag(
        "#{input_prefix}[top_operator_name]",
        options_for_select([['Et', And.name], ['Ou', Or.name]], @condition.class.name)
      )
    end
  end

  def available_targets
    targets = @upper_tdcs.map do |tdc|
      [tdc.libelle, champ_value(tdc.stable_id).to_json]
    end

    if targets.present?
      targets.unshift(['Sélectionner', empty.to_json])
    end

    targets
  end

  def available_operators(left)
    case left.type
    when :boolean
      [
        ['Est', Eq.name]
      ]
    when :empty
      [
        ['Est', Eq.name]
      ]
    when :enum
      [
        ['Est', Eq.name]
      ]
    when :number
      [
        [t('.=='), Eq.name],
        [t('.<'), LessThan.name],
        [t('.>'), GreaterThan.name],
        [t('.<='), LessThanEq.name],
        [t('.>='), GreaterThanEq.name]
      ]
    when :string
      [
        ['Est', Eq.name]
      ]
    else
      []
    end
  end

  def right_input(left, right)
    case left.type
    when :boolean
      select_tag(
        input_value_name,
        options_for_select([['Oui', constant(true).to_json], ['Non', constant(false).to_json]], right.to_json)
      )
    when :empty
      select_tag(
        input_value_name,
        options_for_select([['Sélectionner', empty.to_json]])
      )
    when :enum
      select_tag(
        input_value_name,
        options_for_select(left.type_de_champ.drop_down_list_enabled_non_empty_options, right.value)
      )
    when :number
      number_field_tag(input_value_name, right.value, required: true)
    else
      number_field_tag(input_value_name, '')
    end
  end

  def render?
    available_targets.any?
  end

  def input_value_name
    "#{input_prefix}[rows][][value]"
  end

  def input_prefix
    'type_de_champ[condition_form]'
  end
end
