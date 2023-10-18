# Project Infrastructure

This repository contains the infrastructure setup, deployment scripts, and configurations for the projects.

### Getting Started

To get started, clone the primary infrastructure repository:
```
git clone ssh://git@gitlab.muul.ru:2282/muul/chat_bot/infrastructure.git
```

### Directory Structure After Cloning

Here’s what the project directory will look like:
```
## Configuration Files
infrastructure/
│   ├── traefik.yml
│   ├── conf.d/
│   ├── docker-compose.yml
│   ├── docker_stack_proxy_main.yml
│   ├── docker_stack_ai_chat.yml
│   ├── docker_stack_tg_bot.yml
│   ├── docker_stack_tg_bot_signup.yml
│   └── docker_stack_tg_bot_webhook.yml
```

## Other Repositories

Clone the associated projects:
```
git clone ssh://git@gitlab.muul.ru:2282/muul/chat_bot/ai_chat.git
git clone ssh://git@gitlab.muul.ru:2282/muul/chat_bot/tg_bot.git
```

#### Expected Directory Layout

```
.
├── infrastructure/
├── ai_chat/
└── tg_bot/
```

### Deployment Scripts

- restart_redeploy.sh
- redeploy.sh
- deploy.sh
- stat.sh
- enter_container.sh
- manage_credentials.sh

### Image Handling Scripts

- img_delete.sh
- build_push_all.sh
- build_push_ai_chat.sh
- build_push_tg_bot.sh

### Droplets Management Commands

- clean
- up / down 
- create / delete
- create manager and workers
- join manager
