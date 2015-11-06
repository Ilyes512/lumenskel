Vagrant.require_version ">= 1.5"

# Check to determine whether we're on a windows or linux/os-x host,
# later on we use this to launch ansible in the supported way
# source: https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
        }
    end
    return nil
end

hostname      = "lumenskel.dev"
vbname        = "lumenskel"
server_ip     = "192.168.50.51"
server_cpus   = "1"    # Cores
server_memory = "1024" # MB

Vagrant.configure("2") do |config|

    config.vm.provider :virtualbox do |vb|
        vb.name = vbname

        vb.customize [
            "modifyvm", :id,
            "--name", vbname,
            "--memory", server_memory,
            "--natdnshostresolver1", "on",
            "--cpus", server_cpus,
        ]

        # Set the timesync threshold to 10 seconds, instead of the default 20 minutes.
        # If the clock gets more than 15 minutes out of sync (due to your laptop going
        # to sleep for instance, then some 3rd party services will reject requests.
        vb.customize [
            "guestproperty", "set", :id,
            "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000,
        ]
    end

    config.vm.box = "ubuntu/trusty64"

    config.vm.hostname = hostname

    config.vm.network :private_network, ip: server_ip
    config.ssh.forward_agent = true

    # If ansible is in your path it will provision from your HOST machine
    # If ansible is not found in the path it will be instaled in the VM and provisioned from there
    if which('ansible-playbook')
        config.vm.provision "ansible" do |ansible|
            ansible.playbook       = "ansible/playbook.yml"
            ansible.inventory_path = "ansible/inventories/dev"
            ansible.limit          = "all"
            #ansible.tags           = ['base', 'server', 'php', 'db', 'in-mem-store']
        end
    else
        config.vm.provision :shell, path: "ansible/windows.sh", args: [vbname]
    end

    # Setup the synced folder
    if Vagrant::Util::Platform.windows?
        config.vm.synced_folder ".", "/vagrant",
                  id: "core",
                  :nfs => true,
                  :mount_options => ["dmode=777","fmode=777"]
    else
        # Use NFS for the shared folder
        config.vm.synced_folder ".", "/vagrant",
                  id: "core",
                  :nfs => true,
                  :mount_options => ['nolock,vers=3,udp,noatime,actimeo=2']
    end

    #config.vm.synced_folder "./", "/vagrant", type: "nfs"
end
