describe SungrowRecord do
  subject(:record) { described_class.new(row) }

  let(:row) { CSV::Row.new headers, fields }

  let(:headers) do
    [
      'Zeit',
      'PV-Ertrag(W)',
      'Netz(W)',
      'Batterie(W)',
      'Gesamtverbrauch(W)',
    ]
  end

  describe '#to_h' do
    subject(:hash) { record.to_h }

    context 'without wallbox calculation' do
      let(:fields) do
        [
          '2023-06-21 00:00:00',
          '0',
          '0',
          '402',
          '402',
        ]
      end

      let(:expected_fields) do
        {
          inverter_power: 0,
          house_power: 402,
          bat_power_plus: 0,
          bat_power_minus: 0,
          bat_fuel_charge: nil,
          bat_charge_current: 0.0,
          bat_voltage: 0.0,
          grid_power_plus: 402,
          grid_power_minus: 0,
          wallbox_charge_power: 0,
        }
      end

      it do
        expect(hash).to eq(
          { name: 'SENEC', time: expected_time, fields: expected_fields },
        )
      end
    end
  end
end
