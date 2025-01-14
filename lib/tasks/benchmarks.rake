namespace :benchmarks do
  desc 'Benchmark exports'
  task exports: :environment do
    p_45964 = Procedure.find(45964)
    p_55824 = Procedure.find(55824)
    Benchmark.bm do |x|
      x.report("Démarche 45964") { ProcedureExportService.new(p_45964, p_45964.dossiers).to_xlsx }
      x.report("Démarche 55824") { ProcedureExportService.new(p_55824, p_55824.dossiers).to_xlsx }
    end
  end
end
