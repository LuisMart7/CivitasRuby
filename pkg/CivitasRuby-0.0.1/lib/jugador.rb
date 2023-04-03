#encoding:UTF-8
require_relative 'titulo_propiedad'
require_relative 'sorpresa'
require_relative 'diario'
require_relative 'dado'
module Civitas
  class Jugador
    @@CASAS_MAX = 4
    @@CASAS_POR_HOTEL = 4
    @@HOTELES_MAX = 4
    @@PASO_POR_SALIDA = 1000
    @@PRECIO_LIBERTAD = 200
    @@SALDO_INICIAL = 7500
    
   def initialize (nombre=nil, jugador=nil, amigo=nil)
       if (jugador==nil && amigo==nil)
         @nombre = nombre
         @num_casilla_actual = 0
         @puede_comprar = false
         @saldo = @@SALDO_INICIAL
         @propiedades = []
         @salvoconducto = nil
         @encarcelado = false
         @amigo = amigo
       elsif(nombre==nil && amigo ==nil)
         @nombre = jugador.nombre
         @num_casilla_actual = jugador.num_casilla_actual
         @puede_comprar = jugador.puede_comprar
         @saldo = jugador.saldo
         @propiedades = jugador.propiedades
         @salvoconducto = jugador.salvoconducto
         @encarcelado = jugador.encarcelado
         @amigo = amigo
       else #EXAMEN
         @nombre = nombre
         @num_casilla_actual = 0
         @puede_comprar = false
         @saldo = @@SALDO_INICIAL
         @propiedades = []
         @salvoconducto = nil
         @encarcelado = false
         @amigo = amigo
       end
     end
      
    def self.new_nombre(nombre)
      new(nombre, nil, nil)
    end
    
    def self.new_copia(jugador)
      new(nil, jugador, nil)
    end
    
    #EXAMEN
    def self.new_amigo(nombre, amigo)
      new(nombre, nil, amigo)
    end
    
    #EXAMEN
    def hacer_amigo(amigo)
      romper_amistad
      amigo.romper_amistad
      
      if(@amigo == nil)
        @amigo = amigo
        hacer_amigo(self)
      end
    end
    
    #EXAMEN
    def romper_amistad
      if(@amigo != nil)
        @amigo = nil
        @amigo.romper_amistad
      end
    end
    
    #EXAMEN
    def saludar
      cadena = ""
      
      if(@amigo != nil)
        cadena += "Me llamo #{@nombre} y mi amigos se llama #{@amigo.nombre}"
      else
        cadena += "Me llamo #{@nombre} y no tengo amigos"
      end
      
      return cadena
    end
      
    def perder_salvoconducto
      @salvoconducto.usada;
      @salvoconducto=nil
    end

    def puedo_gastar(precio)
      if @encarcelado
        return false
      else
        return @saldo>=precio
      end
    end

    def existe_la_propiedad(ip)
      return (ip < @propiedades.size && ip >=0)
    end

    def puede_salir_carcel_pagando
      return @saldo>=@@PRECIO_LIBERTAD
    end

    def debe_ser_encarcelado
      if @encarcelado
        return false
      elsif !tiene_salvoconducto
        return true
      else
        perder_salvoconducto
        Diario.instance.ocurre_evento(@nombre+" se libra de la carcel")
        return false
      end
    end

    def encarcelar(num_casilla_carcel)
       if debe_ser_encarcelado
         mover_a_casilla(num_casilla_carcel)
         @encarcelado=true
         Diario.instance.ocurre_evento("#{@nombre} entra en la carcel")
       end
    end

    def obtener_salvoconducto(sorpresa)
      if @encarcelado
        return false
      end
      @salvoconducto=sorpresa
      return true
    end

    def tiene_salvoconducto
      return @salvoconducto != nil
    end

    def puede_comprar_casilla
      @puede_comprar = !@encarcelado
      
      return @puede_comprar
    end

    def paga(cantidad)
      return modificar_saldo(cantidad*(-1.0))
    end

    def paga_impuesto(cantidad)
      if @encarcelado
        return false
      else
        return paga(cantidad)
      end
    end
    
    def paga_alquiler(cantidad)
      resultado = false
      
      if(!@encarcelado)
        resultado = paga(cantidad)
      end
      
      return resultado
    end

    def paga_impuesto(cantidad)
      if @encarcelado
        return false
      else
        return paga(cantidad)
      end
    end

    def recibe(cantidad)
      if @encarcelado
        return false
      else
        return modificar_saldo(cantidad)
      end
    end

    def modificar_saldo(cantidad)
      @saldo += cantidad
      Diario.instance.ocurre_evento("Saldo incrementado en #{cantidad} al jugador #{@nombre}."+"\n")
    end

    def mover_a_casilla(num_casilla)
      if @encarcelado
        return false
      else
        @num_casilla_actual = num_casilla
        @puede_comprar = false
        
        Diario.instance.ocurre_evento("#{@nombre} movido a la casilla #{@num_casilla_actual}")
        return true
      end
    end

    def vender(ip)
      resultado = false
      
      if @encarcelado
        return resultado
      end
      
      if existe_la_propiedad(ip)
        resultado = @propiedades[ip].vender(self)
    
        if resultado
          Diario.instance.ocurre_evento("#{@nombre} vende la propiedad #{@propiedades[ip].nombre}")
          @propiedades.delete_at(ip)
            
          resultado = true
        end
      end

      return resultado
    end

    def tiene_algo_que_gestionar
      return @propiedades.size>0
    end

    def salir_carcel_pagando
      if @encarcelado && puede_salir_carcel_pagando
        paga(@@PRECIO_LIBERTAD)
        @encarcelado=false
        Diario.instance.ocurre_evento("#{@nombre} sale de la carcel pagando #{@@PRECIO_LIBERTAD}")
        
        return true
      else
        return false
      end
    end

    def salir_carcel_tirando
      if Dado.instance.salgo_de_la_carcel
        @encarcelado=false
        Diario.instance.ocurre_evento("#{@nombre} sale de la carcel tirando")
        
        return true
      end
      return false
    end

    def pasa_por_salida
      modificar_saldo(@@PASO_POR_SALIDA)
      Diario.instance.ocurre_evento("#{@nombre} pasa por salida y se lleva #{@@PASO_POR_SALIDA}")
      
      return true
    end
    
    def cantidad_casas_hoteles
      suma=0
      
      for i in 0..@propiedades.size
        suma += @propiedades[i].cantidad_casas_hoteles
      end
      
      return suma
    end

    def en_bancarrota
      return @saldo<0
    end

    def cancelar_hipoteca(ip)
      resultado = false
      
      if @encarcelado
        return resultado
      end
      
      if existe_la_propiedad(ip)
        cantidad = @propiedades[ip].get_importe_cancelar_hipoteca
        
        if(puedo_gastar(cantidad))
          resultado = @propiedades[ip].cancelar_hipoteca(self)
          
          if resultado
            Diario.instance.ocurre_evento("El jugador #{@nombre} cancela la hipoteca de la propiedad #{@propiedades[ip].nombre}")
          end
        end
      end
    end

    def hipotecar(ip)
        resultado = false
        
        if @encarcelado
          return resultado
        end
        
        if existe_la_propiedad(ip)
          resultado = propiedades[ip].hipotecar(self)

          if resultado
            Diario.instance.ocurre_evento("El jugador #{@nombre} hipoteca la propiedad #{@propiedades[ip].nombre}")
          end
        end
    end

    def comprar(titulo)
      resultado = false
      
      if @encarcelado
        return resultado
      end
      
      if @puede_comprar
        precio = titulo.precio_compra
        
        if puedo_gastar(precio)
          resultado = titulo.comprar(self)
          
          if resultado
            @propiedades.push(titulo)
            Diario.instance.ocurre_evento("El jugador #{@nombre} compra la propiedad "+ titulo.to_string)
          end
          @puede_comprar=false;
        end
      end
      
      return resultado
    end
    
    def puedo_construir_casa(titulo)
      importe = titulo.precio_edificar
      return puedo_gastar(importe) && titulo.num_casas < @@CASAS_MAX
    end
    
    def puedo_construir_hotel(titulo)
      importe = titulo.precio_edificar
      return puedo_gastar(importe) && titulo.num_casas == @@CASAS_POR_HOTEL && titulo.num_hoteles < @@HOTELES_MAX
    end

    def construir_casa(ip)
      resultado = false

      if @encarcelado
        return resultado
      end
      
      if(existe_la_propiedad(ip) && puedo_construir_casa(@propiedades[ip]))
        resultado = @propiedades[ip].construir_casa(self)
        
        if resultado
          Diario.instance.ocurre_evento("El jugador #{@nombre} construye casa en la propiedad #{@propiedades[ip].nombre}, CASAS = #{@propiedades[ip].num_casas}, HOTELES = #{@propiedades[ip].num_hoteles}")
        end
      end
      
      return resultado
    end
    
    def construir_hotel(ip)
      resultado = false
      
      if @encarcelado
        return resultado
      end
      
      if (existe_la_propiedad(ip) && puedo_construir_hotel(@propiedades[ip]))
        resultado = @propiedades[ip].construir_hotel(self)
        
        if(resultado)
          @propiedades[ip].derruir_casas(@@CASAS_POR_HOTEL, self)
        
          Diario.instance.ocurre_evento("El jugador #{@nombre} construye un hotel en la propiedad #{@propiedades[ip].nombre}, CASAS = #{@propiedades[ip].num_casas}, HOTELES = #{@propiedades[ip].num_hoteles}")
        end
      end
      
      return resultado
    end

    def is_encarcelado
      return @encarcelado
    end

    def <=>(otro)
      return @saldo <=> otro.saldo
    end
    
    def get_lista_propiedades
        lista = []
        for i in @propiedades
            lista.push(i.nombre)
        end
        return lista
    end
    
    def to_string
      cad = ""
      if(tiene_algo_que_gestionar)
        for i in @propiedades do
          cad += "#{i.nombre}, "
        end
      else
        cad+=" no tiene propiedades"
      end
      
      rep = "Nombre: #{@nombre}
               Saldo: #{@saldo}
               Casilla Actual: #{@num_casilla_actual}
               Encarcelado: #{@encarcelado}
               Propiedades: " + cad + "\n"
      
      #EXAMEN
      if(@amigo != nil)
        rep += "Nombre del amigo: #{@amigo.nombre}\n"
      end
      
      return rep
    end
    
    #EXAMEN
    attr_reader :CASAS_MAX, :CASAS_POR_HOTEL, :HOTELES_MAX, :PASO_POR_SALIDA,
                :PRECIO_LIBERTAD, :SALDO_INICIAL,
                :saldo, :puede_comprar, :num_casilla_actual, :nombre,
                :propiedades, :encarcelado, :amigo
    
    private_class_method :new
    
    private :existe_la_propiedad, :perder_salvoconducto, :puede_salir_carcel_pagando,
      :puedo_construir_casa, :puedo_construir_hotel, :puedo_gastar
  end
end