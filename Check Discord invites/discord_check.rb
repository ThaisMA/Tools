require 'net/http'
require 'json'

begin
  # Lê todos os IDs de uma vez e fecha o arquivo
  ids = File.readlines('ids_invites.txt', chomp: true)
  
  File.open('invites_validos.txt', 'a+') do |output_file|
    ids.each do |id|
      begin
        url = "https://discordapp.com/api/v6/invite/#{id}"
        uri = URI(url)
        response = Net::HTTP.get_response(uri)
        
        if response.code == '200'
          data = JSON.parse(response.body)
          
          # Verifica se o convite é válido e tem informações do servidor, como 'name'. Caso o invite não esteja disponível, não existe o atributo
          if data["guild"] && data["code"]
            guild_name = data["guild"]["name"]
            invite_code = data["code"]
            output_file.puts "https://discordapp.com/invite/#{invite_code} | #{guild_name}"
          end
        end
        
        # Pausa marota para evitar rate limiting
        sleep(1.5)
        
      rescue JSON::ParserError, StandardError => e
        puts "Erro ao processar ID #{id}: #{e.message}"
        next
      end
    end
  end
  
rescue Errno::ENOENT => e
  puts "Arquivo não encontrado: #{e.message}"
rescue StandardError => e
  puts "Erro inesperado: #{e.message}"
end
