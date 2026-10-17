package main

import "core:encoding/json"
import "core:fmt"
import rl "vendor:raylib"

CommandType :: union {
	// session actions
	CommandSessionHello,
	CommandSessionPing,

	// unit actions
	CommandUnitAttack,
	CommandUnitSpawn,
	CommandUnitMove,
}

CommandHeader :: struct {
	action:    string,
	initiator: string,
	timestamp: string,
}

// action:  session.hello
CommandSessionHello :: struct {
	ip:       string,
	nickname: string,
}

// action:  session.ping
CommandSessionPing :: struct {}

// action:  unit.move
CommandUnitMove :: struct {
	id:          string,
	destination: rl.Vector2,
}

// action:  unit.spawn
CommandUnitSpawn :: struct {
	unit_type: string,
	position:  rl.Vector2,
}

// action:  unit.attack
CommandUnitAttack :: struct {
	id:     string,
	target: rl.Vector2,
}


unmarshal_properties :: proc($T: typeid, data: []byte) -> (T, json.Unmarshal_Error) {
	wrapper: struct {
		properties: T,
	}
	err := json.unmarshal(data, &wrapper)
	return wrapper.properties, err
}

parse_command :: proc(data: []byte) -> (header: CommandHeader, cmd: CommandType, ok: bool) {
	if json.unmarshal(data, &header) != nil do return

	err: json.Unmarshal_Error
	switch header.action {
	case "session.hello":
		cmd, err = unmarshal_properties(CommandSessionHello, data)
	case "session.ping":
		cmd, err = unmarshal_properties(CommandSessionPing, data)
	case "unit.spawn":
		cmd, err = unmarshal_properties(CommandUnitSpawn, data)
	case "unit.move":
		cmd, err = unmarshal_properties(CommandUnitMove, data)
	case "unit.attack":
		cmd, err = unmarshal_properties(CommandUnitAttack, data)
	case:
		return // unknown action
	}
	return header, cmd, err == nil
}

print_command :: proc(header: CommandHeader, cmd: CommandType) {
	fmt.printfln("Header:")
	fmt.printfln("  Action:    %s", header.action)
	fmt.printfln("  Initiator: %s", header.initiator)
	fmt.printfln("  Timestamp: %s", header.timestamp)
	fmt.printfln("Payload:")
	switch c in cmd {
	case CommandSessionHello:
		fmt.printfln("  [CommandSessionHello] ip=%s, nickname=%s", c.ip, c.nickname)
	case CommandSessionPing:
		fmt.println("  [CommandSessionPing]")
	case CommandUnitSpawn:
		fmt.printfln("  [CommandUnitSpawn] unit_type=%s, position=(x: %.2f, y: %.2f)", c.unit_type, c.position.x, c.position.y)
	case CommandUnitMove:
		fmt.printfln("  [CommandUnitMove] id=%s, destination=(x: %.2f, y: %.2f)", c.id, c.destination.x, c.destination.y)
	case CommandUnitAttack:
		fmt.printfln("  [CommandUnitAttack] id=%s, target=(x: %.2f, y: %.2f)", c.id, c.target.x, c.target.y)
	}
}

main :: proc() {
	context.allocator = context.temp_allocator

	test_json_commands := [?]string{
		`{
			"action": "session.hello",
			"initiator": "client_1",
			"timestamp": "2026-10-17T12:00:00Z",
			"properties": {
				"ip": "192.168.1.50",
				"nickname": "OdinPlayer"
			}
		}`,
		`{
			"action": "session.ping",
			"initiator": "client_1",
			"timestamp": "2026-10-17T12:00:05Z",
			"properties": {}
		}`,
		`{
			"action": "unit.spawn",
			"initiator": "server",
			"timestamp": "2026-10-17T12:00:10Z",
			"properties": {
				"unit_type": "archer",
				"position": [120.5, 240.0]
			}
		}`,
		`{
			"action": "unit.move",
			"initiator": "client_1",
			"timestamp": "2026-10-17T12:00:15Z",
			"properties": {
				"id": "archer_01",
				"destination": [300.0, 450.75]
			}
		}`,
		`{
			"action": "unit.attack",
			"initiator": "client_1",
			"timestamp": "2026-10-17T12:00:20Z",
			"properties": {
				"id": "archer_01",
				"target": [310.0, 460.0]
			}
		}`,
		`{
			"action": "unknown.command",
			"initiator": "bad_actor",
			"timestamp": "2026-10-17T12:00:25Z",
			"properties": {}
		}`,
	}

	buffer: [1024]byte

	for json_str, i in test_json_commands {
		fmt.printfln("=== Test Case %d ===", i + 1)

		bytes_recv := copy(buffer[:], json_str)
		fmt.printfln("Buffered %d bytes into buffer.", bytes_recv)

		header, cmd, ok := parse_command(buffer[:bytes_recv])
		if !ok {
			fmt.println("Unable to parse command")
			free_all(context.temp_allocator)
			fmt.println()
			continue
		}

		print_command(header, cmd)
		free_all(context.temp_allocator)
		fmt.println()
	}
}

