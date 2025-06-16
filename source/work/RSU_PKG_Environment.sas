%macro GetHostInformation(i_server_no =
								, ovar_host_name =
								, ovar_protocal =
								, ovar_service =
								, ovar_port =
								, ovar_root_url =);
	data _null_;
		attrib
			_uri length = $256.
			_upasn_uri length = $256.
			_com_type length = $256.
			_src_cnn_uri length = $256.
			server_no length = 3.
			protocol length = $6.
			host_name length = $256.
			port length = $4.
			service length = $100.
		;
		call missing(of _all_);
		server_no = &i_server_no.;
		obj_number = metadata_getnobj("omsobj:SoftwareComponent?@Name contains 'Environment Mgr Mid-Tier'" 
												, server_no
												, _uri);
		put obj_number _uri;
		uprc = metadata_getnasn(_uri, 'DeployedComponents', 1, _upasn_uri);
		if (0 < uprc) then do;
			if (metadata_getattr(_upasn_uri, 'Name', _com_type) = 0) then do;
				uprc = metadata_getnasn(_upasn_uri, 'SourceConnections', 1, _src_cnn_uri);
				if (0 < uprc) then do;
					_rc = metadata_getattr(_src_cnn_uri, 'HostName', host_name);
					call symputx("&ovar_host_name.", host_name);
					_rc = metadata_getattr(_src_cnn_uri, 'CommunicationProtocol', protocol);
					call symputx("&ovar_protocal.", protocol);
					_rc = metadata_getattr(_src_cnn_uri, 'Service', service);
					call symputx("&ovar_service.", service);
					_rc = metadata_getattr(_src_cnn_uri, 'Port', port);
					call symputx("&ovar_port.", port);
				end;
			end;
		end;
	run;
	quit;

	%let &ovar_root_url. = &&&ovar_protocal.://&&&ovar_host_name.:&&&ovar_port.;
%mend GetHostInformation;
