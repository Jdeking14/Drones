pragma solidity 0.5.1;

import 'browser/libreriasERC20.sol';

contract DroneManagement is ERC20 {
    using SafeMath for uint256;
    
    
 //#######################################################################################################################
 //############################                   STRUCT           #######################################################
 //#######################################################################################################################
     struct Parcelas {
        uint256 id;
        address propietario;
        int256 longitud;
        int256 alturaMaxPermitida;
        int256 alturaMinPermitida;
        int256 pesticidapermitido;
    }
    
    
     struct Drones{
        uint256 id;//identificador unico
        address owner; // empresa que despliega el contrato
        int256 alturaMax;
        int256 alturaMin;
        int256 autonomia;
        int256 pesticidas; 
        uint256 posicionparcela;
        uint256 coste;
        
    }
    
    struct Trabajo{
        uint256 parcela;
        uint256 precio;
    }
    
    address _empresa;
    address _token;
    address _owner;
    uint256 _amount;
    
    Drones[] public _drones;
    Parcelas[] public _parcelas;
    
    
 //########################################################################################################################
 //############################                   MAPEOS Y EVENTOS  #######################################################
 //########################################################################################################################
    mapping(address => Trabajo) _trabajos;
    
     event parcelaAlmacenada (uint256 _id, address propietario, int256 alturaMax, int256 alturaMin, int256 autonomia, int256 pesticidas);
     event DronAlmacenado (uint256 _id, int256 _alturaMax, int256 _alturaMin, int256 _autonomia, int256 pesticida, uint256 posicionparcela, uint256 _coste);
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event NuevoTrabajo(address);
     
    modifier soloEmpresa(){ // controlo que el codigo puea ser emitido solo por la empresa
        assert(_token == _empresa);
        _;
    }
 //#######################################################################################################################
 //############################                   CONSTRUCTOR      #######################################################
 //#######################################################################################################################
 
    constructor(address token) public{
        _owner = msg.sender;
        _empresa = token;
        _token = token;
        _amount = 0;
        

    }
    
    
 //#######################################################################################################################
 //############################                   CREACION DRONES Y PARCELAS     #########################################
 //#######################################################################################################################
  
   function creaDron(int256 _alturaMax, int256 _alturaMin, int256 _autonomia, int256 _pesticida, uint256 _coste) public soloEmpresa()
    {
        Drones memory dron;
         dron.autonomia = _autonomia;
          
            
        dron.pesticidas = _pesticida;
        
        dron.id = _drones.length;
        
        dron.alturaMax = _alturaMax;
        
        dron.alturaMin = _alturaMin;
        
        dron.autonomia = _autonomia;
        
        dron.posicionparcela = 1;
        
        dron.coste = _coste;
        
        dron.owner = msg.sender;
        
        _drones.push(dron);
        
        emit DronAlmacenado(dron.id, dron.alturaMax, dron.alturaMin, dron.autonomia, dron.pesticidas, dron.posicionparcela, dron.coste);
        
    }
    
   
    
    function crearParcela(int256 _longitud, int256 _alturaMaxPermitida , int256 _alturaMinPermitida, int256 _pesticidapermitido) public 
    {
      
      Parcelas memory parcelas;
      
      parcelas.id = _parcelas.length;
      
      parcelas.propietario = msg.sender;
      
      parcelas.longitud = _longitud;
      
      parcelas.alturaMaxPermitida = _alturaMaxPermitida;
      
      parcelas.alturaMinPermitida = _alturaMinPermitida;
       
      parcelas.pesticidapermitido = _pesticidapermitido;
      
      _parcelas.push(parcelas);
      
      emit parcelaAlmacenada(parcelas.id, parcelas.propietario, parcelas.longitud, parcelas.alturaMaxPermitida, parcelas.alturaMinPermitida,parcelas.pesticidapermitido);
  }
  
    function DesplazarDron(uint dronId, uint parcelaId) soloEmpresa() public
    { 

       require(_parcelas[parcelaId-1].pesticidapermitido == _drones[dronId-1].pesticidas, "No admiten los mismos pesticidas");
       
       if  (_parcelas[parcelaId-1].pesticidapermitido == _drones[dronId-1].pesticidas)
       {     

       require(_drones[dronId-1].autonomia >= _parcelas[parcelaId-1].longitud, "El dron no tiene autonomia suficiente");
       require(_drones[dronId-1].alturaMax <= _parcelas[parcelaId-1].alturaMaxPermitida, "La parcela no soporta la altura max del dron");
       require(_drones[dronId-1].alturaMin >= _parcelas[parcelaId-1].alturaMinPermitida, "El dron no soporta la altura minima de la parcela solicitada");
       
        _drones[dronId-1].posicionparcela = parcelaId; 
       
       }
       
       else
       {
           "El pesticida del dron no es compatible con el pesticida de la parcela";
       }

    }
  
  
 //#######################################################################################################################
 //############################                   FUNCIONES GET            #########################################
 //#######################################################################################################################
  
  
    
    function getDroneLength() public view returns (uint256){
        return _drones.length;
    }
    
    function getParcelaLength() public view returns (uint256){
        return _parcelas.length;
    }
  
   function getEmpresa() public view returns (address){
        return _empresa;
    }
    
    
 function getParcela(uint parcelaId) public view returns(int256,int256,int256,int256,address) {

        return (_parcelas[parcelaId-1].longitud,_parcelas[parcelaId-1].alturaMaxPermitida,
                _parcelas[parcelaId-1].alturaMinPermitida,_parcelas[parcelaId-1].pesticidapermitido,
                _parcelas[parcelaId-1].propietario);
    }

    function getDron(uint dronId) public view returns(int256, int256,int256,int256, uint256, address,uint256) {

        return (_drones[dronId-1].alturaMax,_drones[dronId-1].alturaMin,_drones[dronId-1].autonomia, 
                _drones[dronId-1].pesticidas, _drones[dronId-1].coste,_drones[dronId-1].owner,
                _drones[dronId-1].posicionparcela);
    }
    

         
    
 //#######################################################################################################################
 //############################                  FUNCIONES RELATIVAS AL PAGO     #########################################
 //#######################################################################################################################
    
    ERC20 public libreriasERC20;


function solicitarTrabajo(uint _parcela, uint _cantidad) public{
        _trabajos[msg.sender].parcela = _parcela;
        _trabajos[msg.sender].precio = _cantidad;
        
       emit NuevoTrabajo(msg.sender);
       ERC20.approve(address(this), _cantidad);
       
       _amount = _cantidad;
}

function realizarTrabajo () external payable {
  
  
   for(uint256 did = 0; did < _drones.length; did++){
    	if(_drones[did].alturaMax >= _parcelas[did].alturaMaxPermitida){
    	_drones[did].posicionparcela = _parcelas[did].id;
         require(_amount > 0, "El amount debe ser mayor a 0");
        uint256 initialSupply = _amount.mul(10 ** uint256(9));
        _mint(msg.sender, initialSupply);
        emit Transfer(msg.sender,_empresa,_amount);
        ERC20.transfer(_empresa,_amount);
	      }
        }    
  }   
    
}