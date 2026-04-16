FROM node:22-slim

# 基本工具 + zsh + gh CLI
RUN apt-get update && apt-get install -y \
      git curl ripgrep fd-find jq zsh \
      ca-certificates gnupg \
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
USER claude
WORKDIR /home/claude/workspace

# npm 全域路徑設到 user home，避免 root 權限問題
RUN npm config set prefix '/home/claude/.npm-global' \
    && echo 'export PATH=/home/claude/.npm-global/bin:$PATH' >> ~/.zshrc

ENV PATH=/home/claude/.npm-global/bin:$PATH

# 裝 Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Oh My Zsh（可選，想要漂亮提示字元就留著）
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Statusline: context usage, rate limits, model info
COPY --chown=claude:claude statusline-command.sh /home/claude/.claude/statusline-command.sh
COPY --chown=claude:claude claude-settings.json /home/claude/.claude/settings.json
RUN chmod +x /home/claude/.claude/statusline-command.sh

CMD ["zsh"]
