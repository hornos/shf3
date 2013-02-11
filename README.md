Shell Framework 3
==============

Shell framework is a Bash 3 based script library designed for fast script development.

Basics
-------
The framework is a directory hierarchy which is usually installed into user home. You only need a unix like system. It is tested on Linux and OS X.

Installation
-------------

    cd $HOME
    git clone git://github.com/hornos/shf3.git

Edit your `.bashrc` or `.profile`:

    source $HOME/shf3/bin/shfrc

If you just want to activate it type the command above into your shell.

SSH Wrapper
----------------
The framework contains a sophisticated SSH wrapper. You can use ssh, scp, sshfs and even gsi-ssh in the same manner. The wrapper is independent of the `$HOME/.ssh/config` settings and employs command line arguments only.

For every `user@login` pair you have to create a descriptor file where the options and details of the account is stored. Descriptor files are located in `$HOME/shf3/mid/ssh` directory. The name of the file is a meta-id (MID) which refers to options of the descriptor file. Wrapper commands use the MID for each connection. MIDs are unique and short. All you have to remember is the MID. With the SSH wrapper it is easy to have different SSH keys and options for each account. You can create the MID file from `$HOME/shf3/mid/template.ssh` or create it by the manager:

    sshmgr -n skynet

Optionally, you can generate private/public key pairs. Keys are located in `$HOME/shf3/key/ssh` directory. Secret key is named `MID.sec`, public key is named `MID.pub`. The public part should be added to `authorized_keys` on remote machines.

### Options in the MID file
The MID file is a regular Bash script file, which contains only `key=value` pairs. You can source it from any other script.
    # ssh for regular ssh, gsi for gsi-ssh (see later) 
    mid_ssh_type=ssh
    # FQDN of the remote host
    mid_ssh_fqdn="skynet.cyberdy.ne"
    # remote user name
    mid_ssh_user="$USER"
    # SSH port
    mid_ssh_port=222
    # check port explicitly before connect by nmap
    mid_ssh_port_check="nmap"
    # common SSH options for ssh and scp
    mid_ssh_opt=
    # SSH only options
    mid_ssh_ssh_opt=
    # remote directory where SCP will copy
    mid_ssh_scp_dst="/home/${mid_ssh_user}"
    # SSH tunnel options, eg. proxy redirection
    mid_ssh_tunnel="-L63128:localhost:3128"
    # sshfs remote mount target
    mid_ssh_sshfs_dst="/home/${mid_ssh_user}"
    # sshfs options
    mid_ssh_sshfs_opt=

Login to a remote machine is done by:

    sshto -m MID

Keys will be used if present. If you have tunnels a lock file is created to prevent duplicated redirection. After a not clean logout lock file remains. To force tunnels against the lock run:

  sshto -f -m MID

File or directory transfer can be done between your CWD and `$mid_ssh_scp_dst` directory. To copy a file/dir from CWD:

  sshtx put MID FILE/DIR

To copy back to CWD from `$mid_ssh_scp_dst` run:

  sshtx get MID FILE/DIR

Note that SSH keys, options and port as well as SCP options are used from the MID file. The transfer command employs rsync with ssh therefore it is especially suitable to synchronise large files or directories. Transfers can be interrupted and resumed at will.

You can mount the account with sshfs. All you need is the MID and a valid setting of `mid_ssh_sshfs_dst` in the MID file. Accounts are mounted to `$HOME/sshfs/MID`. To mount a MID:

    sshmnt -m MID

To unmount:

    sshmnt -u MID

Note that you have to install fuse and sshfs for your OS.

The `sshmgr` command can be used to manage your MIDs. You can list your accounts by:

    sshmgr

Get info of an account by:

    sshmgr -i MID


### GSI SSH Support
Login, transfer and mount commands are GSI aware. Instead of your password or private key password the certificate password is asked. Grid proxy is initialized and destroyed automatically. Login proxies are separate. The certificates are sperate from your `$HOME/.globus` settigns.

In order to use GSI you have to include the following options in the MID:

    mid_ssh_type=gsi
    # Grid proxy timeout in HH:MM format
    mid_ssh_valid="12:00"
    # Grid certificate group
    mid_ssh_grid="prace"

Currently, PRACE grid certificates are supported. You can create a grid certificate file in `$HOME/shf3/mid/crt/GRID`, where `GRID` is the name of the grid certificate group. The content of the `GRID` file is:

    mid_crt_url="URL_TO_CERTS.tar.gz"

PRACE is supported out-of-the-box but certificates have to be downloaded or updated by:

    sshmgr -g prace

Certificates are downloaded to `$HOME/shf3/crt/prace` directory. Your grid account certificate should be copied to `$HOME/shf3/key/ssh/MID.crt` and the secret key (pem file) to `$HOME/shf3/key/ssh/MID.sec` . If you create a Grid account with `sshmgr -n` you have to skip SSH key generation and have to do it manually by the following command:

    sshkey -n MID -g URL_TO_OPENSSL_CONFIG

The certificate configuration is used by openssl to generate the secret key and the certificate request. The request is found in `$HOME/shf3/key/ssh/MID.csr` . Note that the sshkey command calls the shf3 password manager to store challenge and request passwords.

Queue Wrapper
------------------
The queue wrapper library is designed to make batch submission of parallel programs very easy. First, you have configure a MID file for the queue. This MID file contains parameters which are same for every submission. Keys and values are scheduler dependent. Currently, Slurm, PBS and SGE is supported. Queue files are located in `$HOME/shf3/mid/que directory`. Key value pairs are:

    # scheduler type: slurm, pbs, sge
    QSCHED=slurm
    # email address for notifications
    QMAILTO=your@email
    # which notifications: abe, ALL
    QMAIL=
    # setup scripts
    QSETUP="$HOME/shf3/bin/machines"
    # ulimits
    QLIMIT="ulimit -s unlimited"
    # exclusive allocation
    QEXCL="yes"

Note that the setup script machines is somewhat mandatory. It sets the variable `MACHINES` to the hostnames of the allocated nodes. You will need this because MPI implementations do not support every scheduler. The `MACHINES` variable is used by the MPI wrapper functions to specify hostnames for the mpirun command. The machines is included in the job script.

The purpose of the wrapper is to write job scripts for the supported schedulers. The scheduler dependent key values are:

    # Slurm account
    QPROJ=
    # Slurm partition
    QPART=
    # Slurm constraints
    QCONST=""
    # SGE queue
    QQUEUE=
    # SGE parallel environment
    QPE=

You can find templates in `$HOME/shf3/mid/que/templates` directory.

### Job Submission
If the queue MID is ready all you need is a job file. The job file is independent of the scheduler and contains only your resource needs. The queue wrapper is designed for MPI or OMP parallel programs. Co-array Fortran and MPI-OMP hybrid mode is also supported. A typical job file is the following (`jobfile`):

    # name of the job
    NAME=test
    # refers to the queue file in shf3/mid/que/skynet
    QUEUE=skynet
    #  the program to run
    RUN="application args"
    # parallel type of run, here MPI-only run with SGI MPT
    MODE=mpi/mpt
    # compute resources: 8 nodes with 2 sockets and 4 cores per socket
    NODES=8
    SCKTS=2
    CORES=4
    # 2 hours wall time
    TIME=02:00:00

To submit your job (batch submission) run:

    jobmgr -b jobfile

This command will run generic checks and shows a summary table of the proposed allocation like that:

      QSCHED NODES SCKTS   CORES GPUS override
       slurm     1     2       4    0  
             SLOTS TASKS sockets      
                 8     8       2       
        MODE    np    pn threads
     mpi/mpt     8     8       1

You can also check the actual, scheduler dependent job script as well. If you have very special needs it is possible to use the wrapper to generate actual job scripts as good starting point. MPI or OMP options are set in various environment variables. You may ask why so serious with parallel submission? Because the above job script is scheduler free and contains only the necessary information. MPI or OMP parameters are error free and calculated accordingly the following table. 

Currently, OpenMPI, Intel MPI, SGI MPT, OpenMP and Co-Array Fortran is supported.

### MPI-OMP hybrid mode
If you specify `MODE=mpiomp` the wrapper configures SCKTS number of MPI process per node and CORES number of OMP threads per MPI process. You can give any combination of SCKTS and CORES. If your scheduler does not support node based allocation like SGE you may have to specify the total number of job slots per node by:

    SLTPN=8

and 8 slots will be allocated per node. If you have a large memory requirement you may have to allocate more cores than MPI processes.

### Application Wrapper
Usually you want to run a script instead of single program.