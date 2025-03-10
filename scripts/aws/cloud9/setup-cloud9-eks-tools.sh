#!/bin/bash

set -e  # 에러 발생 시 스크립트 즉시 종료

echo "🚀 Starting Cloud9 environment setup..."

# Install kubectl
echo "🔧 Installing kubectl..."
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# Install eksctl
echo "🔧 Installing eksctl..."
tar -zxvf eksctl_Linux_amd64.tar.gz
sudo chmod +x eksctl
sudo mv eksctl /usr/local/bin/eksctl

# Install k9s
echo "🔧 Installing k9s..."
tar -zxvf k9s_Linux_amd64.tar.gz
sudo chmod +x k9s
sudo mv k9s /usr/local/bin/k9s

echo "✅ Tool installation completed successfully."

# Install bash-completion
echo "🔧 Installing bash-completion..."
sudo yum install -y bash-completion

# Configure bash aliases & completion
echo "🔧 Configuring shell environment..."

cat <<EOF >>~/.bashrc
# Cloud9 Environment Setup
alias k=kubectl
alias ll='ls -l'

# Enable autocompletion
complete -o default -F __start_kubectl k
source <(kubectl completion bash)
source <(aws completion bash)
source <(docker completion bash)
source <(eksctl completion bash)
source /usr/share/bash-completion/bash_completion
EOF

# Apply changes immediately
echo "✅ Applying changes..."
source ~/.bashrc

echo "🎉 Cloud9 setup completed successfully!"
