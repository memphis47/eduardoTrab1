# This program was created by Rafael Rocha de Carvalho for the class of Distributed Data Management taught at UFPR by Professor Eduardo Almeida. 
# This code is intended to test serialisability Conflicts using a test.in input file and writing the output to file test.out

class Operations
    
    attr_accessor :operationId, :operation, :operationElement
    
    def initialize(opId, op, opElement)  
    # Instance variables  
        @operationId = opId  
        @operation = op 
        @operationElement = opElement
    end
end

class Node
    
    attr_accessor :operationId, :saidas, :entradas
    
    def initialize(opId, saidas, entradas)  
    # Instance variables  
        @operationId = opId  
        @saidas = saidas 
        @entradas = entradas
    end
end


$data = Array.new # array that receive the data from input file
$verifyOperation = Array.new # array that receive the operation elements, e.q if the operation is R(X) then array will receive X, if the operation is W(X) the element X will be removed
$results = Array.new # array with the results of operation, in the format "opNumber opID1,opID2 result(SIM or NAO)"
$op = Array.new # array that receive operationsID
$nodos = Array.new
$opHash =  Hash.new {|h,k| h[k] = Array.new }

$count = 1 # count for result message
$failed = false # boolean to verify if test it was successful or not
$printed = false # boolean to avoid create unnecessary messages
$writable = ""
$oldOperation = nil

# Method that read File and populate data array
def readFile
    File.open("teste.in", "r") do |f|
      f.each_line do |line|
        if line != " " or line != ""
            auxData = line.split
            n = Operations.new(auxData[1],auxData[2],auxData[3])
            $data.push(n)
        end
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
def switchDefinition(operation)
    
    case operation.operation
        when "R"
            $verified = false
            findOperationUsages(operation, "W")
        when "W"
            $verified = false
            findOperationUsages(operation, "R")
            findOperationUsages(operation, "W")
        when "C"
            $opHash =  Hash.new {|h,k| h[k] = Array.new }
            if !$verified and verifyCicle
                $results.push("#{$count}" + " " + createNodosString + " NAO")
            elsif !$verified 
                $results.push("#{$count}" + " " + createNodosString + " SIM")
            end
            $nodos = Array.new
            $verified = true
    end
end

def createNodosString
    auxString = ""
    firsTime = true
    $nodos.each{
        |nodo|
        if(firsTime)
            auxString = "#{nodo.operationId}"
            firsTime = false
        else
            auxString = auxString + "," + "#{nodo.operationId}"
        end
    }
    return auxString
end

def findOperationUsages(operation, opType)
    operationArray = $opHash[opType + operation.operationElement]
    operationArray.each { 
        |ids| 
        if(ids != operation.operationId)
            $nodos[$nodos.find_index {|item| item.operationId == ids}].saidas.push($nodos[$nodos.find_index {|item| item.operationId == operation.operationId}])
            $nodos[$nodos.find_index {|item| item.operationId == operation.operationId}].entradas.push($nodos[$nodos.find_index {|item| item.operationId == ids}])
        end
    }
end

# Method that test the data received from input file
def testDataReceived
    $data.each { 
        |operation|
        if(operation.operation != "C")
            if(!$nodos.any?{|node| node.operationId == operation.operationId})
                $nodos.push(Node.new(operation.operationId,Array.new,Array.new))
            end
            
            $opHash[operation.operation + operation.operationElement].push(operation.operationId)
        end
        switchDefinition(operation)
        
    }
end

def verifyCicle
    
    $nodos.each { 
        |node|
        if(node.entradas.length > 0)
            return findCicle(node, node.operationId ,Array.new)
        end
    }
    return false
end

def findCicle(nodes, idInicio, passed)
    if(!passed.any?{|id| id == nodes.operationId})
        passed.push(nodes.operationId)
        nodes.entradas.each { 
            |node|
            if(node.operationId != idInicio)
                return findCicle(node, idInicio, passed)
            else
                return true
            end    
        }
    else 
        return true
    end
    return false
end

readFile
testDataReceived

writeFile