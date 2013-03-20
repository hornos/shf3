Shell Framework 3
==============

Shell framework is a Bash 3 based script library designed for fast development and advanced bash scripting.

Installation
-------------
the framework is a directory hierarchy which you should install into your `$HOME` directory:

    cd $HOME
    git clone git://github.com/hornos/shf3.git

Enable shf3 by editing your `.bashrc` or `.profile`:

    source $HOME/shf3/bin/shfrc

or activate it by typing the above command into your shell.

### Update
You can update the framewrok from Github by:

    shfmgr -u

### Backup or relocate
The framework is self-contained. All you need to do is copy or move the entire `$HOME/shf3` directory to a new location or a new machine or an encrypted external drive (eg. USB or flash drive). All your SSH keys, GSI certificates and any other configurations are included.

SSH Wrapper
----------------
The framework contains a sophisticated SSH wrapper. You can use ssh, scp, sshfs and even gsi-ssh in the same manner. The wrapper is independent of your `$HOME/.ssh/config` settings and employs command line arguments only.

For every `user@login` pair you have to create a descriptor file where the options and details of the account is stored. Descriptor files are located in `$HOME/shf3/mid/ssh` directory. The name of the file is a meta-id (MID) which refers to the account and its options. Wrapper commands use the MID to identify a connection. MIDs are unique and short. All you have to remember is the MID. With the SSH wrapper it is easy to have different SSH keys and options for each account you have. You can create the MID file from a template file located at `$HOME/shf3/mid/template.ssh` or with the manager.

    sshmgr -n <MID>

The manager asks qestions about the connection and lets you edit the MID file and generates SSH keys if you want. Optionally, you can generate keys by hand. Keys are located in the `$HOME/shf3/key/ssh` directory. Secret key is named `<MID>.sec`, public key is named `<MID>.pub`. The public part should be added to `authorized_keys` on remote machines.

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
    # check mahcine with ping and check port with nmap
    mid_ssh_port_check="ping nmap"
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

#### Additional hostnames
It is possible to have multiple names for a remote host if you want to access it via a VPN or TOR. For the VPN you add:

    mid_vpn_fqdn="<VPN IP>"

Where the `<VPN IP>` is the remote address on the VPN. For the TOR you need:

    mid_tor_fqdn="<ONION NAME>.onion"
    mid_tor_proxy="localhost:9050"

In order to use VPN or tor have have to change `<MID>` to `vpn/<MID>` or `tor/<MID>`, respectively. Note that this notation can be used everywhere insted of a regular MID, so to copy a file over TOR you have to write:

    sshtx put tor/<MID> <FILE>

or if you wan to mount the MID over the vpn:

    sshmnt -m vpn/<MID>

#### SSH hoping

#### Login and file transfer
Login to a remote machine is done by:

    sshto -m <MID>

If you have tunnels a lock file is created to prevent duplicated redirection. After a not clean logout lock file remains. To force tunnels against the lock run:

    sshto -f -m <MID>

File or directory transfer can be done between your CWD and `$mid_ssh_scp_dst` directory. To copy a file/dir from CWD:

    sshtx put <MID> <FILE or DIR>

To copy back to CWD from `$mid_ssh_scp_dst` run:

    sshtx get <MID> <FILE or DIR>

The transfer command employs rsync with ssh and it is especially suitable to synchronise large files or directories. Transfers can be interrupted and resumed at will.

#### Mount
You can mount the account with sshfs. All you need is the MID and a valid setting of `mid_ssh_sshfs_dst` in the MID file. Accounts are mounted to `$HOME/sshfs/<MID>`. To mount a MID:

    sshmnt -m <MID>

To unmount:

    sshmnt -u <MID>

Note that you have to install fuse and sshfs for your OS.

#### MID Manager

The `sshmgr` command can be used to manage your MIDs. You can list your accounts by:

    sshmgr

Get info of an account by:

    sshmgr -i <MID>

Edit a MID file:

    sshmgr -e <MID>


### GSI SSH Support
Login, transfer and mount commands are GSI aware. Grid proxy is initialized and destroyed automatically. Login proxies are separate. Certificates are sperate from your `$HOME/.globus` settings.

In order to use GSI you have to include the following options in the MID:

    mid_ssh_type=gsi
    # Grid proxy timeout in HH:MM format
    mid_ssh_valid="12:00"
    # Grid certificate group
    mid_ssh_grid="prace"

Currently, PRACE grid certificates are supported. You can create a grid certificate file in `$HOME/shf3/mid/crt/<GRID>`, where `<GRID>` is the name of the grid certificate group. The content of the `<GRID>` file is:

    mid_crt_url="<URL of the CERTS>.tar.gz"

PRACE is supported out-of-the-box but certificates have to be downloaded or updated by:

    sshmgr -g prace

Certificates are downloaded to `$HOME/shf3/crt/prace` directory. Your grid account certificate should be copied to `$HOME/shf3/key/ssh/<MID>.crt` and the secret key (pem file) to `$HOME/shf3/key/ssh/<MID>.sec` . If you create a Grid account with `sshmgr -n` you have to skip SSH key generation and have to do it manually by the following command:

    sshkey -n <MID> -g <URL to OPENSSL CONFIG>

The certificate configuration is used by openssl to generate the secret key and the certificate request. The request is found in `$HOME/shf3/key/ssh/<MID>.csr` . Note that the sshkey command calls the shf3 password manager to store challenge and request passwords.

### Encrypted directories
If you install FUSE [encfs https://en.wikipedia.org/wiki/EncFS] you can have encripted directories. MID files or encrypted directories are in `$HOME/shf3/encfs` directory. You can create an encfs MID by:

    encfsmgr -n secret

The MID file has to contain one line:

    # location of the encrypted directory
    mid_encfs_enc="${HOME}/.secret"

Select `p` for pre-configured paranoia mode and type your encryption password. Note that encryption keys ar located in `$HOME/shf3/key/encfs` directory (`<MID>.sec` files) and not in the encrypted directory.

To mount the encrypted directory:

    encfsmnt -m <MID>

Encrypted directories are mounted to `$HOME/encfs/<MID>` . Start to encrypt your secret files by moving stuff into this directory.

Queue Wrapper
------------------
The queue wrapper library is designed to make batch submission of parallel programs very easy. First, you have to configure a MID file for the queue. This MID file contains parameters which are same for every submission. Keys and values are scheduler dependent. Currently, Slurm, PBS and SGE is supported. Queue files are located in `$HOME/shf3/mid/que` directory. The following key/value pairs are common for evry shceduler:

    # scheduler type: slurm, pbs, sge
    QSCHED=slurm
    # email address for notifications
    QMAILTO=your@email
    # which notifications: abe, ALL
    QMAIL=
    # setup scripts
    QSETUP="$HOME/shf3/bin/machines $HOME/shf3/bin/scratch"
    # ulimits
    QLIMIT="ulimit -s unlimited"
    # exclusive allocation
    QEXCL="yes"

Note that the setup script `machines` and `scratch` is somewhat mandatory. The former sets the variable `MACHINES` to the hostnames of the allocated nodes. You will need this because MPI implementations do not support every scheduler. The `MACHINES` variable is used by the MPI wrapper functions to specify hostnames for the `mpirun` command. The latter sets the `SCRATCH` variable to your scratch space. Application Wrapper (see later) needs this. Please check each script if you are in doubt. Prace scratch environment variable (`PRACE_SCRATCH`) is supported.

The purpose of the wrapper is to write job scripts for each scheduler. The scheduler dependent key/value pairs are:

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
    # the program to run
    RUN="<APP> <ARGS>"
    # parallel type of run, here MPI-only run with SGI MPT
    MODE=mpi/mpt
    # compute resources: 8 nodes with 2 sockets and 4 cores per socket
    NODES=8
    SCKTS=2
    CORES=4
    # 2 hours wall time
    TIME=02:00:00

The `QUEUE` refers to the queue MID file (note that it is not real queue of a system). The `RUN` key sets your application, which can be a script if you need complex pre or post-processing. Please note that you ''do not have to explicitly include mpirun'' before your application, the job wrapper does it. Three modes are supported:

1. MPI-only (`MODE=mpi/<MPI>`)
2. MPI-OMP hybrid (`MODE=mpiomp/<MPI>`)
3. OpenMP (`MODE=omp`)
4. Co-Array Fortran(`MODE=caf`)

where `<MPI>` is `opmi` (OpenMPI), `ipmi` (Intel MPI), `mpt` (SGI MPT). MPI parameters and OMP settings are generated according to the `NODES`, `SCKTS` and `CORES` resource needs, which are number of nodes, number of CPU sockets per node, and number of CPU cores per socket, respectively. The following table is used to determine the parameters:

    Par. Mode        # of MPI procs          # of MPI procs/node  # of OMP threads/MPI proc.
    MPI-only (mpi)   NODES × SCKTS × CORES   SCKTS × CORES        1
    OMP-only (omp)   --                      --                   SCKTS × CORES
    MPI-OMP (mpiomp) NODES × SCKTS           SCKTS                CORES

Submit your job file:

    jobmgr -b jobfile

This command will run generic checks and shows a summary table of the proposed allocation like that:

      QSCHED NODES SCKTS   CORES GPUS override
       slurm     1     2       4    0  
             SLOTS TASKS sockets      
                 8     8       2       
        MODE    np    pn threads
     mpi/mpt     8     8       1

You can also check the actual, scheduler dependent, job script as well. If you have special needs it is possible to use the wrapper to generate actual job script. Currently, OpenMPI, Intel MPI, SGI MPT, OpenMP and Co-Array Fortran is supported.

### MPI-OMP hybrid mode
If you specify `MODE=mpiomp` the wrapper configures `SCKTS` number of MPI process per node and `CORES` number of OMP threads per MPI process. You can give any combination of `SCKTS` and `CORES` values. If your scheduler does not support node based allocation like SGE you may have to specify the total number of job slots per node by:

    SLTPN=8

In this case 8 slots are allocated per node. You can use the hybrid mode if want to run a large memory job on low memory nodes by overallocating.

### Application Wrapper
In practice you want to run a script instead of single program. There is no general solution but you can follow this simple scheme:

1. Preprocess inputs and copy them to the scratch directory
2. Run the application
* Collect and postprocess outputs (eg. gzip) and move to submit directory (somewhere in your `$HOME`)

The details of this scheme is application dependent and you have to write wrapper functions for each application. In shf3 there is a general wrapper which does not do application specific input/output processing yet follows this scheme. It is a good starting point to develop new wrappers. The application wrapper does not depend on the queue wrapper, although the queue wrapper detects the application wrapper.

The application wrapper needs a guide file. This file contains information on how to go throught the 3-step scheme. A general guide file contains (`guide`) the following lines:

    # submit dir
    INPUTDIR="${PWD}"
    # scratch dir
    WORKDIR="${SCRATCH}/hpl-${USER}-${HOSTNAME}-$$"
    # result dir, usually the same as submit dir
    RESULTDIR="${INPUTDIR}"
    # application binary and options
    PRGBIN="${HPL_BIN}/xhpl"
    PRGOPT=""
    # data inputs, usually precalculated libraries
    DATADIR=""
    DATA=""
    # main input
    MAIN="-hpl.dat"
    # other inputs, usually for restart
    OTHER=""
    # in case of error outputs are saved
    ERROR="save"
    # patterns for outputs to collect
    RESULT="*"

The `*DIR` variables tell where to copy inputs from: `MAIN` and `OTHER` is realtive to `INPUTDIR`. The `DATA` key is application specific and "relative" to `DATADIR`. The main input is also application specific and can start with a 1 character operator: `-` input is copied but not included int the argument list, `<` input is stdin redirected, and no operator means the input is put into the argument list. The final command is `$PRGBIN $PRGOPT $MAIN` . The program call can be augmented by the queue and the parallel environment. You can run the application with:

    runprg -p general -g guide

This command creates the scratch, copy inputs, run the application, moves back the results and deletes scratch directory. You can combine the two wrappers by setting `RUN="runprg -p general -g guide"` .

## A Full Example
Lets assume we have a cluster named Skynet and we needd access and want to run a job on the machine. Install shf3 on your local machine. First we create an SSH MID for the login:

    sshmgr -n skynet

This command generates keys as well. All you need to do is send the public key to Skynet's administrator. The public key is located in `$HOME/shf3/key/ssh/skynet.pub`. Login to the remote machine:

    sshto -m skynet

Install shf on skynet as well. You need this for the job submission. First you have to setup the queue. On this example machine the job shceduler is Slurm. Create a queue file `$HOME/shf3/mid/que/skynet`:

    QSCHED="slurm"
    QMAILTO="my.email@gmail.com"
    QMAIL="ALL"
    QPROJ="P-20130320"
    QCONST="ib"
    QPART="batch"
    QSETUP="$HOME/shf3/bin/machines $HOME/shf3/bin/scratch"
    QULIMIT="ulimit -s unlimited; ulimit -l unlimited"

All email notification is enabled. The `P-20130320` Slurm account, the `batch` partition and the `ib` Slurm constraint is used. The job script uses two auxiliary scripts (`machines` and `scratch`). The former determines mahcines for the job, the latter sets the scratch space.

Lets assume we want to run a Viennese application VASP. VASP has full support in shf3. You need have the following job file (`vasp.job`):

    NAME=TEST
    TIME=12:00:00
    NODES=2
    SCKTS=2
    CORES=4
    QUEUE=skynet
    MODE="mpi/mpt"
    BIND="dplace -s 1"
    RUN="runprg -p vasp -g vasp.guide"

The name of the job is `TEST` and will run for 12 hours on 2 nodes and 8 cores per node. The queue is `skynet` which refers to the parameters defined in `$HOME/shf3/mid/que/skynet`. The job will run in MPI-only mode and will use the `dplace -s 1` command for CPU binding. In the last line you define the command to run. Here it is the application wrapper for vasp which needs the guide file (`vasp.guide`).

The guide file contains the folllowing lines:

    INPUTDIR="${PWD}"
    WORKDIR="${SCRATCH}/vasp-${USER}-${HOSTNAME}-$$"
    RESULTDIR="${INPUTDIR}"
    PRGBIN="${HOME}/vasp/bin/vasp.mpi"
    PRGOPT=""
    DATADIR="${VASP_PROJ_HOME}/POTCAR_PBE"
    DATA="A B"
    MAIN="-test.cntl"
    OTHER="test.WAVECAR.gz"
    ERROR="save"
    RESULT="*"

Input files copied for the current directory and copied to the `WORKDIR` which is defined be the scratch variable. Results will copied back to the current directory. Old results are saved and compressed by default. The `${HOME}/vasp/bin/vasp.mpi` program will run without any arguments. The `MAIN` variable defines the main input files. If you put `-` as the first character the input is not included in the argument list of the program. Auxiliary data libraries come from `DATADIR` according to `DATA`. An other input is also copied to the scratch space. Other input files are copied and uncompressed as is. All the result files will copied back (`RESULT=*`).

Send your job by:

    jobmgr -b vasp.job

The actual job file will look like this:

    #!/bin/bash
    ### Date Wed Mar 20 10:32:26 CET 2013
    
    ### Scheduler  : slurm
    #SBATCH --job-name TEST
    #SBATCH --mail-type=ALL
    #SBATCH --mail-user=my.email@gmail.com
    #SBATCH --time=12:00:00
    #SBATCH --nodes=2
    #SBATCH --ntasks-per-node=8
    #SBATCH --constraint=ib
    #SBATCH --partition=batch
    #SBATCH -o StdOut
    #SBATCH -e ErrOut
    
    ### Resource Allocation
    #       QSCHED NODES SCKTS   CORES GPUS override
    #        slurm     2     2       4    0  
    #              SLOTS TASKS sockets      
    #                 16     8       4       
    
    ### Queue Setup
    source /home/test/shf3/bin/machines
    source /home/test/shf3/bin/scratch
    ulimit -s unlimited; ulimit -l unlimited
    
    ### MPI Setup
    export MPI_MODE="mpi"
    export MPI_MPI="mpt"
    export MPI_MAX_SLOTS=16
    export MPI_MAX_TASKS=8
    export MPI_NUM_NODES=2
    export MPI_NPPN="8"
    export NODES=2
    export SCKTS=2
    export CORES=4
    export BIND="dplace -s 1"
    export MPI_OPT="   ${MACHINES} @{MPI_NPPN} ${NUMA} @{BIND}  "
    export PRERUN="mpirun ${MPI_OPT}"
    
    ### Fortran Mulit-processing
    export FMP_MPI_NODES=2
    export FMP_MPI_PERNODE=8
    
    ### OMP Setup
    export OMP_NUM_THREADS=1
    export MKL_NUM_THREADS=1
    export KMP_LIBRARY=serial
    
    ### Parallel Mode
    #         MODE    np    pn threads
    #      mpi/mpt    16     8       1 

    ### Command
    runprg -p vasp -g vasp.guide -s slurm

TODO: on SGE

## Advanced job scripts (Kernels)
