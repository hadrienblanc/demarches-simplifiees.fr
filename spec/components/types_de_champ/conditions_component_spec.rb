describe TypesDeChamp::ConditionsComponent, type: :component do
  include Logic

  describe 'render' do
    let(:condition) { nil }
    let(:upper_tdcs) { [] }

    before { render_inline(described_class.new(condition: condition, upper_tdcs: upper_tdcs, procedure_id: 123)) }

    context 'when there are no upper tdc' do
      it { expect(page).not_to have_text('Logique conditionnelle') }
    end

    context 'when there are upper tdc but no condition to display' do
      let(:upper_tdcs) { [build(:type_de_champ)] }

      it do
        expect(page).to have_text('Logique conditionnelle')
        expect(page).to have_button('cliquer pour activer')
        expect(page).not_to have_selector('table')
      end
    end

    context 'when there are upper tdc and a condition' do
      let(:upper_tdcs) { [build(:type_de_champ)] }

      context 'and one condition' do
        let(:condition) { ds_eq(empty, constant(1)) }

        it do
          expect(page).to have_button('cliquer pour desactiver')
          expect(page).to have_selector('table')
          expect(page).to have_selector('tbody > tr', count: 1)
        end
      end

      context 'and 2 conditions' do
        let(:condition) { ds_and([ds_eq(empty, constant(1)), ds_eq(empty, empty)]) }

        it do
          expect(page).to have_selector('tbody > tr', count: 2)
          expect(page).to have_select("type_de_champ_condition_form_top_operator_name", selected: "Et", options: ['Et', 'Ou'])
        end
      end

      context 'when there are 3 conditions' do
        let(:condition) do
          ds_or([
            ds_eq(empty, constant(1)),
            ds_eq(empty, empty),
            greater_than(empty, constant(3)) # TODO ca foire avec champ_value(2) a gauche
          ])
        end

        it do
          expect(page).to have_selector('tbody > tr', count: 3)
          expect(page).to have_select("type_de_champ_condition_form_top_operator_name", selected: "Ou", options: ['Et', 'Ou'])
        end
      end
    end
  end

  describe '.rows' do
    subject { described_class.new(condition: condition, upper_tdcs: [], procedure_id: 123).send(:rows) }

    context 'when there is one condition' do
      let(:condition) { ds_eq(empty, constant(1)) }

      it { is_expected.to eq([[empty, Logic::Eq.name, constant(1), condition]]) }
    end

    context 'when there are 2 conditions' do
      let(:condition) { ds_and([ds_eq(empty, constant(1)), ds_eq(empty, empty)]) }

      let(:expected) do
        [
          [empty, Logic::Eq.name, constant(1), ds_eq(empty, constant(1))],
          [empty, Logic::Eq.name, empty, ds_eq(empty, empty)]
        ]
      end

      it { is_expected.to eq(expected) }
    end

    context 'when there are 3 conditions' do
      let(:condition) do
        ds_or([
          ds_eq(empty, constant(1)),
          ds_eq(empty, empty),
          greater_than(champ_value(2), constant(3))
        ])
      end

      let(:expected) do
        [
          [empty, Logic::Eq.name, constant(1), ds_eq(empty, constant(1))],
          [empty, Logic::Eq.name, empty, ds_eq(empty, empty)],
          [champ_value(2), Logic::GreaterThan.name, constant(3), greater_than(champ_value(2), constant(3))]
        ]
      end

      it { is_expected.to eq(expected) }
    end
  end
end
