# encoding:UTF-8
module Civitas
  class MazoSorpresas
    def initialize(d=false)
      init
      @debug = d
      @ultima_sorpresa=nil
      
      Diario.instance.ocurre_evento("Actualizacion debug a "+@debug.to_s)
      end

    private
    def init
      @sorpresas = []
      @cartas_especiales = []
      @usadas = 0
      @barajada = false
    end
    
    public
    def al_mazo(s)
      if !@barajada
        @sorpresas.push(s)
      end
    end

    public
    def siguiente
      if (!@barajada || @usadas = @sorpresas.length)
        @usadas=0
        @barajada=true
      end
      
      if(!@debug)
        @sorpresas.shuffle
      end
      
      @usadas+=1
      
      @ultima_sorpresa = @sorpresas.shift
      @sorpresas << @ultima_sorpresa
      
      return @ultima_sorpresa
    end

    def inhabilitar_carta_especial(sorpresa)
      if @sorpresas.include?(sorpresa)
        indice = @sorpresas.index(sorpresa)
        @sorpresas.delete_at(indice)
        
        @cartas_especiales << sorpresa
        
        Diario.instance.ocurre_evento("Inhabilitada carta especial "+sorpresa.to_s)
      end
    end

    def habilitar_carta_especial(sorpresa)
      if @cartas_especiales.include?(sorpresa)
        indice = @cartas_especiales.index(sorpresa)
        @cartas_especiales.delete_at(indice)
        
        @sorpresas << sorpresa
        
        Diario.instance.ocurre_evento("Habilitada carta especial "+sorpresa.to_s)
      end
    end

  end
end
