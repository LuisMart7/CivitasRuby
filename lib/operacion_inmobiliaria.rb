#encoding:UTF-8
module Civitas
  class OperacionInmobiliaria
    attr_reader :num_propiedad,
                :gestion
    
    public
    def initialize(gestion, num_propiedad)
        @gestion = gestion
        @num_propiedad = num_propiedad
    end
  end
end