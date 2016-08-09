# coding: utf-8
require 'spec_helper'
require 'limarka'

describe Limarka::Trabalho do
  let (:texto) {'# Texto'}
  let (:anexos) {'# Anexo1\nTexto'}
  let (:configuracao) { {'title' => 'algo'} }
  let (:apendices) {'# Apendice1'}
  let (:referencias_md) {'FULANO. **Título**. Ano.'}
  let (:referencias_bib) {'@book {}'}
  let (:errata) {'Errata1'}
  let(:test_dir) {'tmp/trabalho'}
  
  describe '#new' do
    context 'com argumentos' do
      let(:t) {Limarka::Trabalho.new(configuracao: configuracao, texto: texto, anexos: anexos, apendices: apendices, referencias_md: referencias_md)}
      it 'cria trabalho com as propriedades' do
        expect(t.texto).to eq(texto)
        expect(t.anexos).to eq(anexos)
        expect(t.apendices).to eq(apendices)
        expect(t.referencias).to eq(referencias_md)
        expect(t.configuracao).to include(configuracao)
      end
    end
  end

  describe '.default_texto_file' do
    it 'returna trabalho-academico.md' do
      expect(Limarka::Trabalho.default_texto_file).to eq('trabalho-academico.md')
    end
  end
  describe '.default_anexos_file' do
    it 'returna anexos.md' do
      expect(Limarka::Trabalho.default_anexos_file).to eq('anexos.md')
    end
  end
  describe '.default_apendices_file' do
    it 'returna apendices.md' do
      expect(Limarka::Trabalho.default_apendices_file).to eq('apendices.md')
    end
  end

  describe '.default_apendices_file' do
    subject {Limarka::Trabalho.default_apendices_file}
    it { is_expected.to eq('apendices.md') }
  end

  describe '.default_referencias_bib_file' do
    it 'returna referencias.bib' do
      expect(Limarka::Trabalho.default_referencias_bib_file).to eq('referencias.bib')
    end
  end

  describe '.default_referencias_md_file' do
    it 'returna referencias.md' do
      expect(Limarka::Trabalho.default_referencias_md_file).to eq('referencias.md')
    end
  end

  describe '#referencias_md' do
    let (:t) {Limarka::Trabalho.new(referencias_md: referencias_md)}
    it 'atualiza referencias' do
      expect(t.referencias).to eq(referencias_md)
    end
    it 'atualiza configuracao' do
      expect(t.configuracao).to include({'referencias_md' => true, 'referencias_bib' => false, 'referencias_numerica_inline' => false})
    end
  end

  describe '#referencias_bib' , :erro do
    let (:t) {Limarka::Trabalho.new(referencias_bib: referencias_bib)}
    it 'atualiza referencias' do
      expect(t.referencias).to eq(referencias_bib)
    end
    it 'atualiza configuracao' do
      expect(t.configuracao).to include({'referencias_md' => false, 'referencias_bib' => true, 'referencias_numerica_inline' => false})
    end
  end

  describe '#referencias_inline!' , :erro do
    let (:t) {Limarka::Trabalho.new(referencias_bib: referencias_bib)}
    before do
      t.referencias_inline!
    end
    it 'limpa referências' do
      t.referencias_inline!
      expect(t.referencias).to eq(nil)
    end
    it 'atualiza configuracao' do
      expect(t.configuracao).to include({'referencias_md'=> false, 'referencias_bib' => false, 'referencias_numerica_inline' => true})
    end
  end

  describe '#anexos=' do
    let (:t) {Limarka::Trabalho.new()}
    before do
      t.anexos=anexos
    end
    it 'atualiza valor de anexos' do
      expect(t.anexos).to eq(anexos)
    end
    it 'habilita anexos na configuração' do
      expect(t.configuracao).to include('anexos' => true)
    end
    context 'quando anexos for nil' do
      before do
        t.anexos = nil
      end
      it 'atualiza anexos' do
        expect(t.anexos).to be nil
      end
      it 'desabilita anexos na configuração' do
        expect(t.configuracao).to include('anexos' => false)
      end
    end
  end

  describe '#apendices=' do
    let (:t) {Limarka::Trabalho.new()}
    before do
      t.apendices=apendices
    end
    it 'atualiza valor de apendices' do
      expect(t.apendices).to eq(apendices)
    end
    it 'habilita apêndices na configuração' do
      expect(t.configuracao).to include('apendices' => true)
    end
    context 'quando apendices for nil' do
      before do
        t.apendices = nil
      end
      it 'atualiza apendices' do
        expect(t.apendices).to be nil
      end
      it 'desabilita apêndices na configuração' do
        expect(t.configuracao).to include('apendices' => false)
      end
    end
  end

  describe '#configuracao=' do
    let (:t) {Limarka::Trabalho.new}
    let (:configuracao) {{'title' => 'meu título', 'date' => 'yyyy'}}
    before do
      t.configuracao = configuracao
    end
    it 'atualiza configuração' do
      expect(t.configuracao).to include('title' => 'meu título')
    end
  end
  
  describe '#save' do
    let(:t) {Limarka::Trabalho.new(configuracao: {'title' => 'meu título'}, texto: texto, anexos: anexos, apendices: apendices)}
    before do
      FileUtils.rm_rf test_dir
      FileUtils.mkdir_p test_dir
    end

    context 'quando há apêndice' do
      let(:t) {Limarka::Trabalho.new(apendices: apendices)}
      it 'salva arquivo de apêndices' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_apendices_file)
      end
    end

    context 'quando não há apêndice' do
      let(:t) {Limarka::Trabalho.new(apendices: nil)}
      it 'NÃO salva arquivo de apêndice' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_apendices_file)
      end
    end

    context 'quando há anexos' do
      let(:t) {Limarka::Trabalho.new(anexos: anexos)}
      it 'salva arquivo de anexos' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_anexos_file)
      end
    end

    context 'quando não há anexos' do
      let(:t) {Limarka::Trabalho.new(anexos: nil)}
      it 'NÃO salva arquivo de anexos' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_anexos_file)
      end
    end

    context 'quando há texto' do
      it 'salva arquivo de texto' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_texto_file)
      end
    end

    context 'quando não há texto' do
      let (:t) {Limarka::Trabalho.new}
      it 'não salva arquivo de texto' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_texto_file)
      end
    end
    context 'quando há configuração' do
      before do
        t.save test_dir
      end
      it 'salva arquivo de configuração' do
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_configuracao_file)
      end
    end
    context 'quando há referencias_md' do
      let(:t) {Limarka::Trabalho.new(referencias_md: referencias_md)}
      it 'salva referencias_md' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_referencias_md_file)
      end
    end
    context 'quando há referencias_bib'  do
      let(:t) {Limarka::Trabalho.new(referencias_bib: referencias_bib)}
      it 'salva referencias_bib' do
        t.save test_dir
        expect(File).to exist(test_dir + '/' + Limarka::Trabalho.default_referencias_bib_file)
      end
    end
    context 'quando as referências são inline'  do
      let(:t) {Limarka::Trabalho.new()}
      it 'nenhum arquivo de referências será salvo' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_referencias_bib_file)
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_referencias_md_file)
      end
    end
    context 'quando há errata' do
      let(:t) {Limarka::Trabalho.new(errata: errata)}
      let(:arquivo) {test_dir + '/' + Limarka::Trabalho.default_errata_file}
      let(:conteudo_do_arquivo) {File.open(arquivo, 'r') {|f| f.read}}
      it 'salva arquivo de errata' do
        t.save test_dir
        expect(File).to exist(arquivo)
      end
      it 'conteúdo do arquivo correspondeu a @errata' do
        t.save test_dir
        expect(conteudo_do_arquivo).to eq(errata)
      end

    end

    context 'quando não há errata' do
      let(:t) {Limarka::Trabalho.new(errata: nil)}
      it 'NÃO salva arquivo de errata' do
        t.save test_dir
        expect(File).not_to exist(test_dir + '/' + Limarka::Trabalho.default_errata_file)
      end
    end
        
  end

  describe '#ler_configuracao' do
    let (:arquivo_de_configuracao) {'configuracao.yaml'}
    let (:options) {{configuracao_yaml: arquivo_de_configuracao}}
    let (:configuracao_yaml) {<<-CONF
---
qualquer-chave: valor da chave
---
CONF
}
    let (:t) {Limarka::Trabalho.new}
    context 'quando arquivo de configuração yaml especificado existe' do
      before do
        expect(File).to receive(:open).with(arquivo_de_configuracao,'r').and_yield(
                          StringIO.new(configuracao_yaml))
      end
      it 'ler configuracao do arquivo especificado em options[:configuracao_yaml]' do
        expect(t.ler_configuracao(options)).to include('qualquer-chave' => 'valor da chave')
      end
    end
    context 'quando arquivo de configuração YAML especificado NÃO existe'  do
      before do
        expect(File).to receive(:open).with(arquivo_de_configuracao,'r').and_raise(Errno::ENOENT)
      end
      it 'erro não tratado será lançado' do
        expect { t.ler_configuracao(options) }.to raise_error(Errno::ENOENT)
      end
    end
    
    context 'quando optado por ler configuração de PDF existente', :lento, :libreoffice, :configuracao do
      let (:arquivo_de_configuracao) {'configuracao.pdf'}
      let (:options) {{configuracao_pdf: arquivo_de_configuracao}}
      let (:configuracao_esperada) {{"title" => "Título do trabalho"}}
      before do
        # Precisa do libreoffice e ele precisa está fechado!
        system "libreoffice --headless --convert-to pdf configuracao.odt", :out=>"/dev/null"
        # expect(t).to receive(:ler_configuracao_pdf) {configuracao}
      end
      it 'ler configuracao do arquivo especificado em options[:configuracao_pdf]' do
        expect(t.ler_configuracao(options)).to include(configuracao_esperada)
      end
    end

    context 'quando optado por ler configuração de PDF inexistente', :lento, :libreoffice, :configuracao do
      let (:arquivo_de_configuracao) {'ARQUIVO_NAO_EXISTENTE.pdf'}
      let (:options) {{configuracao_pdf: arquivo_de_configuracao}}
      it 'emite error informando que não encontrou o arquivo' do
        expect {t.ler_configuracao(options)}.to raise_error(IOError, "Arquivo não encontrado: #{arquivo_de_configuracao}")
      end
    end

    
    context 'quando não especificado arquivo de configuração' do
      let (:options) {Hash.new}
      it 'emite ArgumentError informando o ocorrido' do
        expect { t.ler_configuracao(options) }.to raise_error(ArgumentError, 'Faltou especificar o arquivo de configuração em options[configuracao_yaml] ou options[configuracao_pdf]')
      end
    end
  end

  describe '#ler_referencias' do
    let (:t) {Limarka::Trabalho.new}
    context 'quando configurado para ler do arquivo referencias.md', :referencias do
      let (:configuracao) {{'referencias_md' => true}}
      it 'ler o arquivo e retorna seu conteúdo' do
        expect(t).to receive(:ler_referencias_md)
        t.ler_referencias(configuracao)
      end
    end
    context 'quando configurado para ler do arquivo referencias.bib', :referencias do
      let (:configuracao) {{'referencias_bib' => true}}
      it 'ler o arquivo e retorna seu conteúdo' do
        expect(t).to receive(:ler_referencias_bib)
        t.ler_referencias(configuracao)
      end
    end
  end

  describe '#ler_apendices' do
    let (:arquivo) {'apendices.md'}
    context 'quando EXISTE apendices.md', :apendices do
      let (:configuracao) {{'apendices' => true}}
      let (:t) {Limarka::Trabalho.new}
      let (:conteudo) {apendices}
      before do
        expect(File).to receive(:open).with(arquivo,'r').and_yield(
                         StringIO.new(conteudo))
      end
      it 'ler o arquivo e retorna seu conteúdo' do
        t.configuracao = configuracao
        expect(t.ler_apendices).to eq(conteudo)
      end
    end
  end

end