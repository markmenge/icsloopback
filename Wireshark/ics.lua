-- This Lua script defines Wireshark dissectors for analyzing Intrepid CAB1 and CAB2 protocol packets.
-- Put this file into your plugin folder. Mine is: C:\Users\mmenge\AppData\Roaming\Wireshark\plugins
-- Import the ics profile: Wireshark.exe, menu Edit, Configuration Profiles, Import, select file: ics_profile.zip
-- Enter for display filter: eth.type == 0xCAB1 || eth.type == 0xCAB2
-- Open one of the .npcap or .pcap captures.
-- Ctrl-Shift-L reloads the Lua plugins
-- Status: work-in-progress

local function createProtocol(name, desc, type)
	local ics = Proto(name, desc)
	-- Define fields of the protocol
	-- Field Name ("PaySize"): This is a string that uniquely identifies the field within the protocol. It's used in your Lua script to refer to this particular field. Think of it as a variable name for the field within your dissector or post-dissector code.
	-- Field Label ("ics.paysize"): This string is what will be displayed in the packet details pane in Wireshark for this field. It's a more descriptive or human-readable name
	local pay_size = ProtoField.uint16("PaySize", "ics.paysize")
	local pack_num = ProtoField.uint16("PackNum", "ics.packnum")
	local hdr_start = ProtoField.uint32("HdrStart", "ics.hdrstart", base.HEX)
	local hdr_stat = ProtoField.uint8("HdrStat", "ics.hdrstat", base.HEX)
	local hdr_prot = ProtoField.uint8("HdrProt", "ics.hdrprot", base.HEX)

	local cmd_aa = ProtoField.uint8("CmdAA", "ics.cmdaa", base.HEX)
	local cmd_netid = ProtoField.uint8("CmdNetId", "ics.cmdnetid", base.HEX)
	local cmd_len = ProtoField.uint8("CmdLen", "ics.cmdlen")
	local cmd_num = ProtoField.uint8("CmdNum", "ics.cmdnum", base.HEX)
	local cmd_data = ProtoField.bytes("CmdData", "ics.cmddata")
	local cmd_NetIDRed = ProtoField.uint8("cmd_NetIDRed", "ics.cmd_NetIDRed", base.HEX)
    local msg_data = ProtoField.bytes("MsgData", "ics.data")

	-- Register fields
	ics.fields = { 
		pay_size,
		pack_num,
		hdr_start, 
		hdr_stat,
		hdr_prot,
		cmd_aa,
		cmd_netid,
		cmd_len,
		cmd_num,
		cmd_data,
		cmd_NetIDRed,
        msg_data
	}
	
	local command_names = {
	[0x07] = "EnableNetworkCommunication",
	[0x08] = "EnableNetworkCommunicationEx",
	[0xA1] = "RequestSerialNumber",
	[0xA3] = "GetMainVersion", -- Previously known as RED_CMD_APP_VERSION_REQ
	[0xA4] = "SetSettings", -- Previously known as RED_CMD_SET_BAUD_REQ, follow up with SaveSettings to write to EEPROM
	[0xA5] = "GetSettings", -- Previously known as RED_CMD_READ_BAUD_REQ, now unused
	[0xA6] = "SaveSettings",
	[0xA7] = "UpdateLEDState",
	[0xA8] = "SetDefaultSettings", -- Follow up with SaveSettings to write to EEPROM
	[0xA9] = "GetSecondaryVersions", -- Previously known as RED_CMD_PERIPHERALS_APP_VERSION_REQ, versions other than the main chip
	[0xBC] = "RequestStatusUpdate",
	[0xC7] = "ReadSettings", -- Previously known as 3G_READ_SETTINGS_EX
	[0xDB] = "SetVBattMonitor", -- Previously known as RED_CMD_CM_VBATT_MONITOR
	[0xDC] = "RequestBitSmash", -- Previously known as RED_CMD_CM_BITSMASH
	[0xDF] = "GetVBattReq", -- Previously known as RED_CMD_VBATT_REQUEST
	[0xE7] = "MiscControl",
	[0xF3] = "FlexRayControl"
	}

	local net_ids = {
		[0] = "NETID_DEVICE",
		[1] = "NETID_HSCAN",
		[2] = "NETID_MSCAN",
		[3] = "NETID_SWCAN",
		[4] = "NETID_LSFTCAN",
		[5] = "NETID_FORDSCP",
		[6] = "NETID_J1708",
		[7] = "NETID_AUX",
		[8] = "NETID_JVPW",
		[9] = "NETID_ISO",
		[10] = "NETID_ISOPIC",
		[11] = "NETID_MAIN51",
		[12] = "NETID_RED",
		[13] = "NETID_SCI",
		[14] = "NETID_ISO2",
		[15] = "NETID_ISO14230",
		[16] = "NETID_LIN",
		[17] = "NETID_OP_ETHERNET1",
		[18] = "NETID_OP_ETHERNET2",
		[19] = "NETID_OP_ETHERNET3",
		[41] = "NETID_ISO3",
		[42] = "NETID_HSCAN2",
		[44] = "NETID_HSCAN3",
		[45] = "NETID_OP_ETHERNET4",
		[46] = "NETID_OP_ETHERNET5",
		[47] = "NETID_ISO4",
		[48] = "NETID_LIN2",
		[49] = "NETID_LIN3",
		[50] = "NETID_LIN4",
		[51] = "NETID_MOST",
		[52] = "NETID_RED_APP_ERROR",
		[53] = "NETID_CGI",
		[54] = "NETID_3G_RESET_STATUS",
		[55] = "NETID_3G_FB_STATUS",
		[56] = "NETID_3G_APP_SIGNAL_STATUS",
		[57] = "NETID_3G_READ_DATALINK_CM_TX_MSG",
		[58] = "NETID_3G_READ_DATALINK_CM_RX_MSG",
		[59] = "NETID_3G_LOGGING_OVERFLOW",
		[60] = "NETID_3G_READ_SETTINGS_EX",
		[61] = "NETID_HSCAN4",
		[62] = "NETID_HSCAN5",
		[63] = "NETID_RS232",
		[64] = "NETID_UART",
		[65] = "NETID_UART2",
		[66] = "NETID_UART3",
		[67] = "NETID_UART4",
		[68] = "NETID_SWCAN2",
		[69] = "NETID_ETHERNET_DAQ",
		[70] = "NETID_DATA_TO_HOST",
		[71] = "NETID_TEXTAPI_TO_HOST",
		[72] = "NETID_SPI1",
		[73] = "NETID_OP_ETHERNET6",
		[74] = "NETID_RED_VBAT",
		[75] = "NETID_OP_ETHERNET7",
		[76] = "NETID_OP_ETHERNET8",
		[77] = "NETID_OP_ETHERNET9",
		[78] = "NETID_OP_ETHERNET10",
		[79] = "NETID_OP_ETHERNET11",
		[80] = "NETID_FLEXRAY1A",
		[81] = "NETID_FLEXRAY1B",
		[82] = "NETID_FLEXRAY2A",
		[83] = "NETID_FLEXRAY2B",
		[84] = "NETID_LIN5",
		[85] = "NETID_FLEXRAY",
		[86] = "NETID_FLEXRAY2",
		[87] = "NETID_OP_ETHERNET12",
		[90] = "NETID_MOST25",
		[91] = "NETID_MOST50",
		[92] = "NETID_MOST150",
		[93] = "NETID_ETHERNET",
		[94] = "NETID_GMFSA",
		[95] = "NETID_TCP",
		[96] = "NETID_HSCAN6",
		[97] = "NETID_HSCAN7",
		[98] = "NETID_LIN6",
		[99] = "NETID_LSFTCAN2",
	}
	
    -- Dissector function
    function ics.dissector(buffer, pinfo, tree)
		local info_str = "buffer:len():" .. tonumber(buffer:len()) .. " "
        
  		-- Set protocol name in the packet details
		pinfo.cols.protocol:set(desc)

		-- Check if there's enough data to decode
		if buffer:len() < 14 then
			pinfo.cols.info:set(info_str)
			return
		end
		-- Create a subtree for our protocol
		local subtree = tree:add(ics, buffer(), "ics")
		-- subtree:add(neo_data, buffer(0, buffer:len()):string())
		-- Add fields to the subtree
		--subtree:add(src_mac_field, buffer(0, 6))
		--subtree:add(dst_mac_field, buffer(6, 6))
		--subtree:add(ethertype_field, buffer(12, 2))

		-- Old UpdateLEDState command
		subtree:add(msg_data, buffer(0, buffer:len() - 1))
		if (buffer(10, 1):uint() == 0xAA and buffer(12, 1):uint() == 0 and buffer(13, 1):uint() == 6) then
			subtree:add(cmd_data, buffer(13))	-- data
			pinfo.cols.info:set("Old UpdateLEDState command")
			return
		end
  
		subtree:add(hdr_start, buffer(0, 4))
		local payload_size = buffer(4, 2):le_uint()
		subtree:add_le(pay_size, buffer(4, 2))
		subtree:add_le(pack_num, buffer(6, 2))
		subtree:add(hdr_stat, buffer(8, 1))
		subtree:add(hdr_prot, buffer(9, 1))

		subtree:add(cmd_aa, buffer(10, 1))
		local id_len = buffer(11, 1):uint();
		local cmd_len_value = bit.rshift(id_len, 4)
		
		-- short command
		if cmd_len_value > 0 then
			info_str = info_str .. "Ics Short"
			local networkID = bit.band(id_len, 0x0f)
			subtree:add(cmd_netid, networkID)
			subtree:add(cmd_len, cmd_len_value)
			subtree:add(cmd_data, buffer(13))	-- data
			local cmd = buffer(12, 1):uint()
			local command_name = command_names[cmd]
			if command_name then
				subtree:add(cmd_num, buffer(12, 1)):append_text(", " .. command_name)
				info_str = info_str .. ", " .. command_name .. ", " .. net_ids[networkID]
			else
				subtree:add(cmd_num, buffer(12, 1)):append_text(", Unknown command (Tx CAN Message?)")
				info_str = info_str .. ", " .. "Tx CAN Message" .. ", " .. net_ids[networkID]
			end
			pinfo.cols.info:set(info_str)
			return
		end

		-- long command
		info_str = info_str .. "Ics  Long buffer:len():" .. tonumber(buffer:len()) .. " "
        pinfo.cols.info:set(info_str)
		local NetIDRed = buffer(11, 1):uint()
		local packetLength = buffer(12, 2):le_uint()
		local command = buffer(14, 1):uint()
		local networkID = buffer(13, 2):uint()
		local networkIDStr = net_ids[networkID]

		subtree:add(cmd_NetIDRed, NetIDRed)
		subtree:add(cmd_len, packetLength)
		-- subtree:add(cmd_netid, networkID)
		-- subtree:add(cmd_netid, networkID):append_text("  " .. tonumber(networkID))
		
		if networkIDStr then
			subtree:add(cmd_netid, networkID):append_text(" (" .. tonumber(networkID) .. ") " .. networkIDStr)
		else
			subtree:add(cmd_netid, networkID):append_text(" (" .. tonumber(networkID) .. ")")
		end
		
		if NetIDRed == 0xc then
			subtree:add(cmd_NetIDRed, NetIDRed):append_text(NetIDRed):append_text(", " .. "Tx CAN Message")
			info_str = info_str .. ", " ..  "Tx CAN Message"
			subtree:add(cmd_num, command)
		else
			local command_name = command_names[command]
			if command_name then
				subtree:add(cmd_num, buffer(14, 1)):append_text(", " .. command_name)
				info_str = info_str .. ", " ..  command_name
			else
				-- If the command value is not recognized, display it as hexadecimal
				subtree:add(cmd_num, buffer(14, 1)):append_text(", Unknown command" .. command)
				info_str = info_str .. ", " ..  ", Unknown command"
			end
		end

		if payload_size > 3 then
			subtree:add(cmd_data, buffer(13))
		end

		-- Update standard info column
		if networkIDStr then
			info_str = info_str .. ", " .. networkIDStr
		end
		pinfo.cols.info:set(info_str)
		
		-- Specify how many bytes this dissector processed
		return buffer:len()
    end

    -- Register the protocol as a dissector
    DissectorTable.get("ethertype"):add(type, ics)
end


createProtocol("ICSClient", "ICS-Client", 0xcab1)
createProtocol("ICSServer", "ICS-Server", 0xcab2)


-- Register our protocol as a dissector for Ethernet packets
--DissectorTable.get("ethertype"):add(0xcab1, neo_client)
--DissectorTable.get("ethertype"):add(0xcab2, neo_client)
