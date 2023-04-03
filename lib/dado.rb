# encoding:UTF-8
module Civitas
  class Dado    
    def initialize
      @rnd = nil
      @ultimo_resultado = 0
      @debug=false
    end
    
    @@instance = new
    @@salida_carcel = 5
    
    def self.instance
      @@instance
    end
    
    def tirar
      if !@debug
        @rnd=rand(6)+1
        @ultimo_resultado=@rnd
      else
        @ultimo_resultado=1
      end
      return @ultimo_resultado
    end
    
    def salgo_de_la_carcel
      resultado=tirar
      return resultado==@@salida_carcel
    end
    
    def quien_empieza(n)
      return rand(n)+1
    end
    
    def set_debug(d)
      @debug=d
      Diario.instance.ocurre_evento("Actualizacion debug a "+@debug.to_s)
    end
    
    private_class_method :new
    
    attr_reader :ultimo_resultado
  end
end
