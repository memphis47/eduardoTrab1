class Node
    
    attr_accessor :operationId, :operation, :operationElement
    
    def initialize(opId, op, opElement)  
    # Instance variables  
        @operationId = opId  
        @operation = op 
        @operationElement = opElement
    end
end


data = Array.new
File.open("teste.in", "r") do |f|
  f.each_line do |line|
    auxData = line.split
    n = Node.new(auxData[1],auxData[2],auxData[3])
    data.push(n)
  end
end


verifyOperation = Array.new
results = Array.new
op = Array.new
count = 1

failed = false
printed = false

data.each { 
    |node| 
    if !op.include?(node.operationId)
        op.push(node.operationId)
    end
    case node.operation
        
        when "R"
            printed = false
            if !verifyOperation.include?(node.operationElement)
                puts "add #{node.operationElement}"
                verifyOperation.push(node.operationElement)
            end
        when "W"
            printed = false
            if verifyOperation.include?(node.operationElement)
                puts "removing #{node.operationElement}"
                verifyOperation.delete(node.operationElement)
            else
                failed = true
            end
        when "C"
            if !failed and !printed
                results.push("#{count}" + " " + "#{op[0]}" + "," + "#{op[1]}" + " SIM")
            elsif !printed 
                results.push("#{count}" + " " + "#{op[0]}" + "," + "#{op[1]}" + " NAO")
            end
            failed = false
            printed = true
            verifyOperation = Array.new
            op = Array.new
            count = count.to_i + 1
    end
          
    
}

File.open("teste.out", "w+") do |f|
    results.each{
        |result|
        f.puts(result)
    }
end


