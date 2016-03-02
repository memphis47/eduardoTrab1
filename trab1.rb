# This program was created by Rafael Rocha de Carvalho for the class of Distributed Data Management taught at UFPR by Professor Eduardo Almeida. 
# This code is intended to test serialisability Conflicts using a test.in input file and writing the output to file test.out

class Node
    
    attr_accessor :operationId, :operation, :operationElement
    
    def initialize(opId, op, opElement)  
    # Instance variables  
        @operationId = opId  
        @operation = op 
        @operationElement = opElement
    end
end


$data = Array.new # array that receive the data from input file
$verifyOperation = Array.new # array that receive the operation elements, e.q if the operation is R(X) then array will receive X, if the operation is W(X) the element X will be removed
$results = Array.new # array with the results of operation, in the format "opNumber opID1,opID2 result(SIM or NAO)"
$op = Array.new # array that receive operationsID
$count = 1 # count for result message
$failed = false # boolean to verify if test it was successful or not
$printed = false # boolean to avoid create unnecessary messages
$writable = ""
$oldOperation = nil

# Method that read File and populate data array
def readFile
    File.open("teste.in", "r") do |f|
      f.each_line do |line|
        auxData = line.split
        n = Node.new(auxData[1],auxData[2],auxData[3])
        $data.push(n)
      end
    end
end

# Method that write the results in the output file
def writeFile
    File.open("teste.out", "w+") do |f|
        $results.each{
            |result|
            f.puts(result)
        }
    end
end

# Method that verify if lastOperation don't affect actual operation
def verifyLastOperation(operationType, node)
    if(!$oldOperation.nil?)
        if ($oldOperation.operationElement.eql? node.operationElement and $oldOperation.operation.eql? operationType and $oldOperation.operationId != node.operationId)
                        $failed = true
        end
    end
end

# Method that define what program should do when a operation happens
def switchDefinition(operation, node)
    
    case operation
        when "R"
            $printed = false
            verifyLastOperation("W", node)
            if !$failed and !$verifyOperation.include?(node.operationElement)
                $verifyOperation.push(node.operationElement)
            end
            $oldOperation = node
        when "W"
            $printed = false
            verifyLastOperation("R", node)
            if !$failed and $verifyOperation.include?(node.operationElement)
                $verifyOperation.delete(node.operationElement)
            else
                $failed = true
            end
            $oldOperation = node
        when "C"
            if !$failed and !$printed
                $results.push("#{$count}" + " " + "#{$op[0]}" + "," + "#{$op[1]}" + " SIM")
            elsif !$printed 
                $results.push("#{$count}" + " " + "#{$op[0]}" + "," + "#{$op[1]}" + " NAO")
            end
            $failed = false
            $printed = true
            $verifyOperation = Array.new
            $op = Array.new
            $count = $count.to_i + 1
            $writable = ""
            $oldOperation = nil
    end
end

# Method that test the data received from input file
def testDataReceived
    $data.each { 
        |node| 
        if !$op.include?(node.operationId)
            $op.push(node.operationId)
        end
        switchDefinition(node.operation, node)
    }
end

readFile
testDataReceived
writeFile