require 'spec_helper_acceptance'

describe 'moodle class' do
  context 'with required parameters only' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = %{
        $install_dir = '/opt/www/dokuwiki'
        class { 'apache':
          mpm_module => 'prefork',
        }
        class { 'apache::mod::php': }
        apache::vhost { $::fqdn:
          docroot        => $install_dir,
          manage_docroot => false,
          port           => '80',
          override       => 'All',
        }
        class { 'dokuwiki':
          install_dir => $install_dir,
          wiki_title => 'My Test Wiki',
        }
      }

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe port(80) do
      it { should be_listening }
    end

  end
end
