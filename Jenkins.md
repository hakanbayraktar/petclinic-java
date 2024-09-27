EKS cluster kurulumu
EKS Cluster oluşturun:

eksctl create cluster \
  --name my-eks-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2

Kubeconfig güncelleyin:

aws eks --region us-east-1 update-kubeconfig --name my-eks-cluster

EKS cluster için bir IAM OIDC sağlayıcısı oluşturun
eksctl utils associate-iam-oidc-provider \
   --region us-east-1 \
   --cluster my-eks-cluster \
   --approve


AWS load balancer için IAM politikasını indirin:
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json

AWSLoadBalancerControllerIAMPolicy adlı bir IAM politikası oluşturun

aws iam create-policy \
   --policy-name AWSLoadBalancerControllerIAMPolicy \
   --policy-document file://iam-policy.json

Döndürülen politika ARN'sini not edin.
Önceki adımdaki ARN'yi kullanarak AWS Yük Dengeleyici Denetleyicisi için bir IAM rolü ve ServiceAccount oluşturun:

eksctl create iamserviceaccount \
   --cluster=my-eks-cluster \
   --namespace=kube-system \
   --name=aws-load-balancer-controller \
   --attach-policy-arn=arn:aws:iam::905418438096:policy/AWSLoadBalancerControllerIAMPolicy \
   --override-existing-serviceaccounts \
   --approve
----------------
# Jenkins sunucu
### 1- Jenkins Kurulumu
url -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/devops/jenkins/install/jenkins-install.sh | sudo bash
Jenkis Arayüzünü kurulumu tamamla (şifreyi kullan)
pluginleri kur:
pipeline stage
aws credential
docker 

### 2- Docker Kurulumu
Docker kullanarak imaj oluşturup push edeceksiniz, bu yüzden Docker'ı kurun:
curl -s https://raw.githubusercontent.com/hakanbayraktar/ibb-tech/refs/heads/main/docker/ubuntu-24-docker-install.sh | sudo bash
docker izinleri
sudo chmod 666 /var/run/docker.sock
sudo usermod -aG docker jenkins

### kubectl install on ubuntu
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

### aws cli kur
sudo apt install curl unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

### sonarqube install
