# For this lab, I didn't do the extra credit (basically didn't do the jupyter part), but completed the main web application section
# vms-terraform



## Getting started

- If you want to do this lab please tell your instructor beforehand so the correct permissions can be granted for your account.

- There are three main ways to create cloud resourcres in gcp (other cloud providers offer similar choices)
    
    - You can use the interactive console
    - You can use gcloud commands
    - You can a third-party package called terraform which can be thought of building infrastructure in code

- In the spirit of this class we will be using terraform. With terraform you can describe virtually every aspect of the machine(s) you wish to build.

- This entire lab will be done inside a cloud shell. You can open a cloud console by going to console.cloud.google.com. Near the top right portion of the page you will see a square with >_ inside it.  By clicking on the square you will open your cloud shell.



## Making a website

### Initial information 

- You will neeed to follow the following instructions to add to your main.tf file.
- Wherever you see USERNAME below put your username or any other unique identifier. 
- Where you see XX replace it with a random number between 2 and 250.
- Use the same USERNAME and XX for the entire lab.
- The entire class is sharing the same project
- Using the same name can potentially confuse terraform

- For this portion of the lab you will be working in the web directory and editing the main.tf file.



### Setting of the network

We will begin by setting up the network for our cluster.  If you want you can look of vpc_network but is generally beyond the scope of this class. We are basically creating some rules on what machines can talk to each other. We will say the network is going to be created in us-central-1 (Iowa).

```
resource "google_compute_network" "vpc_network" {
  name                    = "USERNAME-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "USERNAME-subnet"
  ip_cidr_range = "10.0.XX.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}
```

###  Create a single Compute Engine instance

We will begin by describing a single instance. In this case it will be a very small micro-server. This machine will exist in zone a of us-central-1. We will say that we want to install debina-11 on the boot disk. We are adding the tag to allow ssh into the node.

resource "google_compute_instance" "default" {
  name         = "flask-USERNAME-vm"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  ### Install Flask

Flask is one of the most basic of webservers written in python.  We are going to give instructions when the node is created to install flask by setting the metadata_startup_script.

We will also tell terraform to give the node an external IP address.

```
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
```

### Starting up the node

Use the command 

```
terraform init
```

to initialize the terraform environment. Run the command

```
terraform plan
```

to make sure you have a valid configuration.

Finally startup the instance with

```
terraform apply
```

### Connect to the node
Connect to the VM with SSH
Validate that everything is set up correctly at this point by connecting to the VM with SSH.

- Go to the VM Instances page.

- Find the VM with the name flask-USERNAME-vm.

- In Connect column, click SSH.

- An SSH-in-browser terminal window opens for the running VM.

### Build the Flask app
- You build a Python Flask app for this tutorial so that you can have a single file describing your web server and test endpoints.

- In the SSH-in-browser terminal, create a file called app.py.

```
nano app.py
```

- Add the following to the app.py file:

```
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_cloud():
  return 'Hello Cloud!'

app.run(host='0.0.0.0')
```

- Run app.py:

```
python3 app.py
```

- Open a second SSH connection:

- Go to the VM Instances page.
- Find the VM named flask-USERNAME-vm and click SSH.
In the second SSH connection, run curl to confirm that the greeting that you configured in app.py is returned.


- curl http://0.0.0.0:5000

### Open port 5000 on the VM

- To connect to the web server from your local computer, the VM must have port 5000 open. Google Cloud lets you open ports to traffic by using firewall rules.

- Add the following google_compute_firewall Terraform resource at the end of your main.tf file.

```
resource "google_compute_firewall" "flask" {
  name    = "flask-app-USERNAME-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}
```

- In Cloud Shell, run terraform apply to create the firewall rule.

- Add an output variable for the web server URL
- At the end of main.tf, add a Terraform output variable to output the web server URL:

```
// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip,":5000"])
}
```

- Run terraform apply.

```
terraform apply
```

When prompted, enter yes. Terraform prints the VM's external IP address and port 5000 to the screen, as follows:

```
Web-server-URL = "http://IP_ADDRESS:5000"
```

At any time, you can run terraform output to return this output:

```
terraform output
```

- Click the URL from the previous step, and see the "Hello Cloud!" message.

- This means that your server is running.


## Make a jupyterlab server

If you want a real challlenge (optional) and extra credit

With the following clues (and looking at the docker lab) you can build (in the jupyter directory) a jupyterlab node that you can build and destroy preserving its state

- Your startup script could
    - Install and start docker
    - Run a docker build
    - Start a docker container
    - Could do a gsutil cp -r into a local directory from storage 
        - For example you could store all your notebooks in gs:://sep-storage/USERNAME/notebooks
        - Automatically copy that directory locally
        - Mount that director to /home/jovyan in the docker

- You can specify a [shutdown script] [https://stackoverflow.com/questions/67200932/gce-shutdown-script-in-terraform]
    - That shutdown script could copy all of your notebooks to the bucket directory above

- In order to read/write to storage you need to give the created node permission. The best way to do this through a service account. You can see an example [here][https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance]
    - The service account sep-cluster-access@sep-storage.iam.gserviceaccount.com has the correct permission


