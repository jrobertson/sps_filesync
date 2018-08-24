#!/usr/bin/env ruby

# file: sps_filesync.rb

require 'sps-sub'
require 'drb_fileclient'


class SpsFileSync < SPSSub


  def initialize(nodes=[], port: '59000', host: nil, log: nil, debug: false)
    
    raise 'SpsFileSync::initialize nodes.empty' if nodes.empty?
    
    @nodes, @debug = nodes, debug
    super(port: port, host: host, log: log)
    
  end  
  
  def subscribe(topic: 'file/*')
    
    super(topic: topic + ' or nodes or nodes/*') do |msg, topic|

      if msg =~ /^dfs:\/\// then
      
        if @debug then
          puts 'topic: ' + topic.inspect
          puts 'msg: ' + msg.inspect
        end
        
        action = topic.split('/').last.to_sym

        @master_address , path = msg.match(/^dfs:\/\/([^\/]+)(.*)/).captures

        case action
        when :cp

          src, dest = msg.split(/ +/,2)

          file_op do |f, node|
            src_path = "dfs://%s%s" % [node, src[/^dfs:\/\/[^\/]+(.*)/]]
            target_path = "dfs://%s%s" % [node, dest[/^dfs:\/\/[^\/]+(.*)/]]
            f.cp src_path, target_path
          end
          
        when :mkdir
          
          file_op {|f, node| f.mkdir "dfs://%s%s" % [node, path] }

        when :mkdir_p
          
          file_op {|f, node| f.mkdir_p "dfs://%s%s" % [node, path] }            
          
        when :mv

          src, dest = msg.split(/ +/,2)

          file_op do |f, node|
            src_path = "dfs://%s/%s" % [node, src[/^dfs:\/\/[^\/]+(.*)/]]
            target_path = "dfs://%s/%s" % [node, dest[/^dfs:\/\/[^\/]+(.*)/]]
            f.mv src_path, target_path
          end                  
                
        when :write

          master_path = msg

          file_op do |f, node|
            target_path = "dfs://%s%s" % [node, path]
            
            if @debug then
              puts 'master_path: ' + master_path.inspect
              puts 'target_path: ' + target_path.inspect
            end
                      
            DfsFile.cp master_path, target_path

          end
          
        when :rm
          
          file_op {|f, node| f.rm "dfs://%s%s" % [node, path] }      
        
        when :zip

          master_path = msg

          file_op do |f, node|
            target_path = "dfs://%s%s" % [node, path]
            f.cp master_path, target_path
          end 
          
        end

      elsif topic == 'nodes/set' 
        @nodes = msg.split(/ +/)
      elsif topic == 'nodes' and msg == 'get'
      
        notice 'nodes/listed: ' + @nodes.join(' ')
      end
    end
  end

  private

  def file_op()

    (@nodes - [@master_address]).each do |node|
      
      puts 'node: ' + node.inspect if @debug
      
      begin
        yield(DfsFile, node)
      rescue
        'warning: node: ' + node + ' ' + ($!).inspect
      end
      
    end

  end

end
