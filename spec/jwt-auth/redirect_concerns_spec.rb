class TestRedirector; include JwtAuth::RedirectConcerns; end

describe JwtAuth::RedirectConcerns do
	before do
		clear_config
		JwtAuth.config.assign(mandatory_config.merge(run_config))
	end

	subject { TestRedirector.new }

	describe '#redirect_to' do
		let(:run_config) { {logger: logger} }

		context 'when passed redirect target and status' do
			it 'logs its action' do
				expect(logger).to receive(:info).with("jwt-auth: redirect:#{target} status:#{status}").once
				subject.redirect_to(target, status)
			end
			it 'returns a rack response array' do
				rack_response = subject.redirect_to(target, status)[2]
				expect(rack_response.status).to eq(status)
				expect(rack_response.location).to eq(target)
				expect(rack_response.body).to eq(['Redirecting you to '+target])
			end
		end

		context 'when passed redirect target only' do
			it 'logs its action w/ 302 status' do
				expect(logger).to receive(:info).with("jwt-auth: redirect:#{target} status:302").once
				subject.redirect_to(target)
			end
			it 'returns a rack response array w/ 302 status' do
				rack_response = subject.redirect_to(target)[2]
				expect(rack_response.status).to eq(302)
				expect(rack_response.location).to eq(target)
				expect(rack_response.body).to eq(['Redirecting you to '+target])
			end
		end
		let(:logger) { NullLogger.new }
		let(:status) { Random.rand(900) }
		let(:target) { junk_route }
	end

	describe '#default_target' do
		context 'with assigned url_root + assigned default target' do
			let(:run_config) { { url_root: root, default_redirect_target: target } }

			it 'returns default redirect target' do
				expect(subject.default_target).to eq target
			end
		end
		context 'with assigned url_root + unassigned default target' do
			let(:run_config) { mandatory_config.merge({ url_root: root }) }

			it 'returns url_root' do
				expect(subject.default_target).to eq root
			end
		end
		context 'with unassigned url_root + assigned default target' do
			let(:run_config) { mandatory_config.merge({ default_redirect_target: target }) }

			it 'returns default redirect target' do
				expect(subject.default_target).to eq target
			end
		end
		context 'with unassigned url_root + unassigned default target' do
			let(:run_config) { {} }

			it 'returns "/"' do
				expect(subject.default_target).to eq '/'
			end
		end
		let(:root) { junk_route }
		let(:target) { junk_route }
	end

end
