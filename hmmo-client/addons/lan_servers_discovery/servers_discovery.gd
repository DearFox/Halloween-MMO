extends Node

signal scanned_server(data:JSON)
signal scanned

var client :PacketPeerUDP
var server :UDPServer

var server_data := {'Name':''}
var scanned_servers := []

var is_scanning:bool = false
var is_servering:bool = false

var port:int = 4040
var scan_time:float = 5

# Список широковещательных адресов для сканирования
var broadcast_addresses:PackedStringArray = [
	"192.168.0.255",
	"192.168.1.255",
	"192.168.2.255",
	"192.168.3.255",
	"10.0.0.255",
	"10.0.1.255",
	"172.16.0.255",
	"172.17.0.255",
	"172.18.0.255",
	"172.19.0.255",
	"172.20.0.255",
	"255.255.255.255"
]

func scan_lan_servers():
	#print("scan_lan_servers")
	# 启动客户端
	client = PacketPeerUDP.new()
	client.set_broadcast_enabled(true)
	# Отправляем запрос на каждый широковещательный адрес
	for addr in broadcast_addresses:
		print(client.set_dest_address(addr, port))
		client.put_var({'type': 'get_server'})
		# Небольшая задержка между отправками, чтобы не перегружать сеть
		await get_tree().create_timer(0.1).timeout
	#client.set_dest_address("255.255.255.255", port)
	#client.put_var({'type':'get_server'})
	# 设置Timer等待2秒后完成扫描
	get_tree().create_timer(scan_time).timeout.connect(_on_timer_timeout)

	scanned_servers = []
	is_scanning = true

func set_server():
	server = UDPServer.new()
	server.listen(port,'0.0.0.0')
	is_servering = true
	
func close_server():
	server.stop()
	is_servering = false

func _process(delta):
	if is_scanning:
		if client.get_available_packet_count() > 0:
			var data= client.get_packet().decode_var(0)
			var server_ip = client.get_packet_ip()
			data['server_ip'] = server_ip
			data.erase('type')
			scanned_servers.append(data)
			scanned_server.emit(data)
			
	if is_servering:
		server.poll()
		if server.is_connection_available():
			var peer: PacketPeerUDP = server.take_connection()
			if peer.get_packet().decode_var(0)['type'] == 'get_server':
				peer.put_var({'type':'server_data','server_data':server_data})

func _on_timer_timeout():
	is_scanning = false
	client.close()
	scanned.emit()
