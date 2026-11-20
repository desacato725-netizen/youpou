# Music Menu — compilação mobile

Este projeto é um novo app Expo/React Native separado da IPA original. Ele não altera o executável `Inter`.

## O que já está implementado

- Login local de demonstração em português.
- E-mail de demonstração preenchido na tela.
- Menu lateral de perfil inspirado na referência enviada.
- Itens em português: Adicionar conta, Seu Premium, Novidades, Recentes, Suas atualizações, Configurações e privacidade e Mensagens.
- Tela de Configurações e privacidade.
- Tela principal de música com busca visual, biblioteca, capas, fotos e player.
- Player com play/pause, próxima faixa e barra de progresso.
- Três faixas de demonstração configuradas por URL, para serem substituídas pelos arquivos autorizados do projeto.

## Executar localmente

```bash
pnpm install
pnpm dev
```

O preview Expo/Metro usa a porta 8081 e o servidor auxiliar usa a porta 3000.

## Substituir as músicas

Edite `app/(tabs)/index.tsx` e troque os valores `cover` e `uri` do array `tracks` por arquivos e capas que você tenha autorização para distribuir. Para uso offline, coloque os arquivos em `assets/audio/` e use `require()` no lugar das URLs remotas.

## Compilar no GBox

1. Envie este repositório para o Git que o GBox utiliza.
2. No GBox, abra o projeto como Expo/React Native.
3. Instale as dependências com `pnpm install` ou o comando equivalente do GBox.
4. Gere o build iOS usando o certificado e o provisioning profile da sua conta Apple.
5. Assine e exporte a IPA pelo fluxo normal do GBox.

O Bundle ID de desenvolvimento deste projeto é `space.manus.musicmenu.t276911253596979`. Se o GBox exigir outro Bundle ID, altere-o em `app.config.ts` antes do build.

A IPA original permanece fora deste projeto e não é modificada.
