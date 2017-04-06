describe JwtAuth::PathEntry do

	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
	end

	describe 'object creation' do
		subject { JwtAuth::PathEntry.new(path_entry_arg) }

		context 'valid arguments' do
			it 'returns a PathEntry instance' do
				expect(subject).to be_an_instance_of(JwtAuth::PathEntry)
			end
		end
		context 'missing key "route"' do
			before { path_entry_arg.delete(:route) }
			it 'raises configuration error' do
				expect{ subject }.to raise_error(JwtAuth::PathEntry::Error)
			end
		end
		context 'empty string under "route" key' do
			before { path_entry_arg.merge!({route: ''}) }
			it 'raises PathEntry error' do
				expect{ subject }.to raise_error(JwtAuth::PathEntry::Error)
			end
		end
		context 'missing (optional) "verb" key' do
			before { path_entry_arg.delete(:verb) }
			it 'returns a PathEntry instance' do
				expect(subject).to be_an_instance_of(JwtAuth::PathEntry)
			end
		end
		context 'unrecognized value under verb' do
			before { path_entry_arg.merge!({verb: 'psot'}) }
			it 'raises PathEntry error' do
				expect{ subject }.to raise_error(JwtAuth::PathEntry::Error)
			end
		end
		context 'missing (optional) "params" key' do
			before { path_entry_arg.delete(:params) }
			it 'returns a PathEntry instance' do
				expect(subject).to be_an_instance_of(JwtAuth::PathEntry)
			end
		end
		context 'unassigned term under params' do
			before { path_entry_arg.merge!( {params: {junk => nil}}) }
			it 'raises PathEntry error' do
				expect{ subject }.to raise_error(JwtAuth::PathEntry::Error)
			end
		end
		let(:path_entry_arg) { junk_path_entry }
	end

	describe 'JwtAuth::PathEntry::Error' do
		subject { raise JwtAuth::PathEntry::Error }
		it 'can be captured as JwtAuth::Configuration::Error' do
			expect{ subject }.to raise_error(JwtAuth::Configuration::Error)
		end
	end

	describe '#match?' do

		subject { JwtAuth::PathEntry.new(con_arg).match?(last_request) }

		context 'unassigned url root' do
			let(:run_config) { {} }
			context 'request has route + verb + params' do
				before { send(req_arg[:verb], req_arg[:route], req_arg[:params]) }

				let(:req_arg) { default_arg }

				context 'configuration matches route + matches verb + matches exact params' do
					let(:con_arg) { default_arg }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration matches route + matches verb + expects extra params' do
					let(:con_arg) { merge_junk_into_params (deep_clone_entry(default_arg)) }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + matches verb + matches a subset of params' do
					let(:con_arg) { delete_first_param_key(deep_clone_entry(default_arg)) }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration matches route + mismatches verb + matches exact params' do
					let(:con_arg) { mismatch_verb( deep_clone_entry( default_arg ) ) }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + expects extra params' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_verb(c_arg)
						merge_junk_into_params(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + matches a subset of params' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_verb(c_arg)
						delete_first_param_key(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + matches exact params' do
					let(:con_arg) { mismatch_route( deep_clone_entry(default_arg) ) }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + matches some params (extra)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						merge_junk_into_params(c_arg)
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + matches some params (missing)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_route(c_arg)
						delete_first_param_key(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + matches verb + (params not config)' do
					let(:con_arg) { delete_all_params( deep_clone_entry( default_arg ) ) }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration mismatches route + matches verb + (params not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						delete_all_params(c_arg)
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + (params not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						delete_all_params(c_arg)
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						delete_all_params(c_arg)
						delete_verb(c_arg)
					end
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration mismatches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_route(c_arg)
						delete_all_params(c_arg)
						delete_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
			end
			context 'request has route + verb' do
				before { send(req_arg[:verb], req_arg[:route]) }

				let(:req_arg) { delete_all_params( deep_clone_entry( default_arg ) ) }

				context 'configuration matches route + matches verb + expecting params' do
					let(:con_arg) { default_arg }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + matches verb + not expecting params' do
					let(:con_arg) { delete_all_params( deep_clone_entry( default_arg ) ) }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration matches route + mismatches verb + expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + not expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + not expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						delete_verb(c_arg)
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						delete_verb(c_arg)
					end
					it 'true' do
						expect(subject).to be true
					end
				end
			end
		end
		context 'assigned url root' do
			let(:run_config) { {url_root: root} }
			context 'request has route + verb + params' do
				before { send(req_arg[:verb], root_path(req_arg), req_arg[:params]) }

				let(:req_arg) { default_arg }

				context 'configuration matches route + matches verb + matches exact params' do
					let(:con_arg) { default_arg }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration matches route + matches verb + expects extra params' do
					let(:con_arg) { merge_junk_into_params (deep_clone_entry(default_arg)) }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + matches verb + matches a subset of params' do
					let(:con_arg) { delete_first_param_key(deep_clone_entry(default_arg)) }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration matches route + mismatches verb + matches exact params' do
					let(:con_arg) { mismatch_verb( deep_clone_entry( default_arg ) ) }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + expects extra params' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_verb(c_arg)
						merge_junk_into_params(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + matches a subset of params' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_verb(c_arg)
						delete_first_param_key(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + matches exact params' do
					let(:con_arg) { mismatch_route( deep_clone_entry(default_arg) ) }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + matches some params (extra)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						merge_junk_into_params(c_arg)
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + matches some params (missing)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_route(c_arg)
						delete_first_param_key(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + matches verb + (params not config)' do
					let(:con_arg) { delete_all_params( deep_clone_entry( default_arg ) ) }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration mismatches route + matches verb + (params not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						delete_all_params(c_arg)
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + (params not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						delete_all_params(c_arg)
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						delete_all_params(c_arg)
						delete_verb(c_arg)
					end
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration mismatches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry(default_arg)
						mismatch_route(c_arg)
						delete_all_params(c_arg)
						delete_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
			end
			context 'request has route + verb' do
				before { send(req_arg[:verb], root_path(req_arg)) }

				let(:req_arg) { delete_all_params( deep_clone_entry( default_arg ) ) }

				context 'configuration matches route + matches verb + expecting params' do
					let(:con_arg) { default_arg }
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + matches verb + not expecting params' do
					let(:con_arg) { delete_all_params( deep_clone_entry( default_arg ) ) }
					it 'true' do
						expect(subject).to be true
					end
				end
				context 'configuration matches route + mismatches verb + expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + mismatches verb + not expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + matches verb + not expecting params' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						mismatch_route(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration mismatches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						delete_verb(c_arg)
						mismatch_verb(c_arg)
					end
					it 'false' do
						expect(subject).to be false
					end
				end
				context 'configuration matches route + (params + verb not config)' do
					let(:con_arg) do
						c_arg = deep_clone_entry( default_arg )
						delete_all_params(c_arg)
						delete_verb(c_arg)
					end
					it 'true' do
						expect(subject).to be true
					end
				end
			end
			let(:root) { junk_route }
			def root_path(req_arg)
				root + req_arg[:route]
			end
		end
		let(:default_arg) { junk_path_entry }
		let(:app) { NullAppStub.new }
		def deep_clone_entry(entry)
			doppleganger = entry.clone
			doppleganger[:params] = entry[:params].clone
			doppleganger
		end
		def delete_first_param_key(entry)
			key = entry[:params].keys.first
			entry[:params].delete(key)
			entry
		end
		def merge_junk_into_params(entry)
			entry[:params].merge!({junk => junk})
			entry
		end
		def mismatch_verb(entry)
			old_verb = entry[:verb]
			new_verb = [:post,:get,:delete,:put,:patch].reject{|e| e==old_verb}.sample
			entry[:verb] = new_verb
			entry
		end
		def mismatch_route(entry)
			entry[:route] = junk_route
			entry
		end
		def delete_all_params(entry)
			entry.delete(:params)
			entry
		end
		def delete_verb(entry)
			entry.delete(:verb)
			entry
		end
	end
	let(:run_config) { {} }
end
