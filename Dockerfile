FROM node:22-slim

# 基本工具 + zsh + gh CLI
RUN apt-get update && apt-get install -y \
      git curl wget ripgrep fd-find jq zsh \
      openssh-client make vim nano \
      ca-certificates gnupg \
      python3 python3-pip python3-venv pipx \
      default-jdk \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# 非 root 使用者，shell 設成 zsh
RUN useradd -m -s /usr/bin/zsh claude
# 還在 root 身份時先把目錄建好
RUN mkdir -p /home/claude/.config/gh /home/claude/.zsh-history \
    && chown -R claude:claude /home/claude/.config /home/claude/.zsh-history

USER claude
WORKDIR /home/claude/workspace

# Python 套件管理 (uv)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH=/home/claude/.local/bin:$PATH

# npm 全域路徑設到 user home，避免 root 權限問題
RUN npm config set prefix '/home/claude/.npm-global' \
    && echo 'export PATH=/home/claude/.npm-global/bin:$PATH' >> ~/.zshrc

ENV PATH=/home/claude/.npm-global/bin:$PATH

# 裝 Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Oh My Zsh（可選，想要漂亮提示字元就留著）
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && echo 'export HISTFILE=/home/claude/.zsh-history/.zsh_history' >> ~/.zshrc

# Statusline: context usage, rate limits, model info
COPY --chown=claude:claude statusline-command.sh /home/claude/.claude/statusline-command.sh
COPY --chown=claude:claude claude-settings.json /home/claude/.claude/settings.json
RUN chmod +x /home/claude/.claude/statusline-command.sh

CMD ["zsh"]
