# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
# @author Ronaldo Araujo
module Brcobranca
  module Boleto
    class Santander < Base # Banco Santander

      # Usado somente em carteiras especiais com registro para complementar o número do cocumento
      attr_reader :seu_numero

      # Deve ser utilizado pois para o código de barra o numero 102 deve ser enviado. 
      # Já para o boleto renderizado, pode ser utilizada a sigla da carteira (atributo carteira)
      attr_accessor :carteira_numero

      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :convenio, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."
      validates_length_of :numero_documento, :maximum => 12, :message => "deve ser menor ou igual a 12 dígitos."
      validates_length_of :conta_corrente, :maximum => 9, :message => "deve ser menor ou igual a 9 dígitos."
      validates_length_of :seu_numero, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."

      # Nova instancia do Santander
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {carteira_numero: "102",
                  carteira: 'CSR',
                  conta_corrente: '00000' # Obrigatória na classe base
                  }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "033"
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 5 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(5,'0') if valor
      end

      # Conta corrente
      # @return [String] 5 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(5,'0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 8 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(12,'0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 7 caracteres numéricos.
      def seu_numero=(valor)
        @seu_numero = valor.to_s.rjust(7,'0') if valor
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        self.numero_documento.modulo11_2to9_santander
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "000090002720-7"
      def nosso_numero_boleto
        "#{self.numero_documento}-#{self.nosso_numero_dv}"
      end

      # Agência + codigo do cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0059/1899775"
      def agencia_conta_boleto
        "#{self.agencia}/#{self.convenio}"
      end

      # Segunda parte do código de barras.
      # 9(01) | Fixo 9 <br/>
      # 9(07) | Convenio <br/>
      # 9(13) | Nosso Numero<br/>
      # 9(01) | IOF<br/>
      # 9(03) | Carteira de cobrança<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "9#{self.convenio}#{self.numero_documento}#{self.nosso_numero_dv}0#{self.carteira_numero}"
      end

    end
  end
end
