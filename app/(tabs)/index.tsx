import { Ionicons } from "@expo/vector-icons";
import { useAudioPlayer, useAudioPlayerStatus } from "expo-audio";
import { useMemo, useState } from "react";
import {
  Image,
  Linking,
  Modal,
  Pressable,
  ScrollView,
  StatusBar,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View,
} from "react-native";

const DEMO_EMAIL = "sleep128@gmail.com";
const DEMO_PASSWORD = "sleepffx9017";
const ORIGINAL_APP_URL = "threeoneosfive://";

const tracks = [
  {
    id: "lana",
    title: "Faixa da Lana Del Rey",
    artist: "Lana Del Rey",
    cover: "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=800&q=80",
    uri: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    color: "#5c3c65",
  },
  {
    id: "kevin",
    title: "Faixa do MC Kevin",
    artist: "MC Kevin",
    cover: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80",
    uri: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    color: "#8f4639",
  },
  {
    id: "kanye",
    title: "Faixa do Kanye West",
    artist: "Kanye West",
    cover: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80",
    uri: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    color: "#334f65",
  },
];

function Brand({ compact = false }: { compact?: boolean }) {
  return (
    <View style={styles.brandRow}>
      <View style={styles.brandMark}>
        <Ionicons name="musical-notes" size={compact ? 18 : 22} color="#111" />
      </View>
      {!compact && <Text style={styles.brandText}>musicmenu</Text>}
    </View>
  );
}

export default function HomeScreen() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [email, setEmail] = useState(DEMO_EMAIL);
  const [password, setPassword] = useState(DEMO_PASSWORD);
  const [loginError, setLoginError] = useState("");
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [screen, setScreen] = useState<"home" | "settings">("home");
  const [selectedId, setSelectedId] = useState(tracks[0].id);
  const [showPassword, setShowPassword] = useState(false);
  const [privateAccount, setPrivateAccount] = useState(false);
  const selected = useMemo(
    () => tracks.find((track) => track.id === selectedId) ?? tracks[0],
    [selectedId],
  );
  const player = useAudioPlayer(selected.uri, { updateInterval: 250 });
  const status = useAudioPlayerStatus(player);

  const openTrack = (id: string) => {
    const track = tracks.find((item) => item.id === id) ?? tracks[0];
    setSelectedId(track.id);
    player.replace(track.uri);
    player.play();
  };

  const nextTrack = () => {
    const index = tracks.findIndex((track) => track.id === selectedId);
    openTrack(tracks[(index + 1) % tracks.length].id);
  };

  const login = () => {
    if (email.trim() === DEMO_EMAIL && password === DEMO_PASSWORD) {
      setLoginError("");
      setLoggedIn(true);
      return;
    }
    setLoginError("E-mail ou senha de demonstração incorretos.");
  };

  if (!loggedIn) {
    return (
      <View style={styles.loginScreen}>
        <StatusBar barStyle="light-content" />
        <View style={styles.loginGlowOne} />
        <View style={styles.loginGlowTwo} />
        <View style={styles.loginContent}>
          <Brand />
          <View style={styles.loginCopy}>
            <Text style={styles.eyebrow}>SUA MÚSICA, DO SEU JEITO</Text>
            <Text style={styles.loginTitle}>Bem-vindo{`\n`}de volta.</Text>
            <Text style={styles.loginSubtitle}>
              Entre para ouvir suas faixas e continuar de onde parou.
            </Text>
          </View>
          <View style={styles.form}>
            <Text style={styles.inputLabel}>E-mail</Text>
            <TextInput
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              keyboardType="email-address"
              style={styles.input}
              placeholder="seu@email.com"
              placeholderTextColor="#777"
            />
            <View style={styles.passwordLabelRow}>
              <Text style={styles.inputLabel}>Senha</Text>
              <Text style={styles.mutedSmall}>Acesso de demonstração</Text>
            </View>
            <View style={styles.passwordInputWrap}>
              <TextInput
                value={password}
                onChangeText={setPassword}
                secureTextEntry={!showPassword}
                style={styles.passwordInput}
                placeholder="Sua senha"
                placeholderTextColor="#777"
              />
              <Pressable onPress={() => setShowPassword((value) => !value)} hitSlop={12}>
                <Ionicons name={showPassword ? "eye-off-outline" : "eye-outline"} size={21} color="#999" />
              </Pressable>
            </View>
            {!!loginError && <Text style={styles.errorText}>{loginError}</Text>}
            <Pressable style={styles.primaryButton} onPress={login}>
              <Text style={styles.primaryButtonText}>Entrar</Text>
              <Ionicons name="arrow-forward" size={20} color="#111" />
            </Pressable>
            <Pressable style={styles.demoButton} onPress={login}>
              <Text style={styles.demoButtonText}>Usar acesso de demonstração</Text>
            </Pressable>
          </View>
          <Text style={styles.loginFooter}>Ao continuar, você concorda com nossos termos e política de privacidade.</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.app}>
      <StatusBar barStyle="light-content" />
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <View style={styles.topBar}>
          <Pressable onPress={() => setDrawerOpen(true)} style={styles.avatarButton}>
            <View style={styles.avatar}><Text style={styles.avatarText}>S</Text></View>
            <View><Text style={styles.greeting}>Boa noite</Text><Text style={styles.userName}>sleep128</Text></View>
          </Pressable>
          <View style={styles.topActions}>
            <Pressable style={styles.circleButton}><Ionicons name="notifications-outline" size={21} color="#f5f5f5" /></Pressable>
            <Pressable style={styles.circleButton}><Ionicons name="settings-outline" size={21} color="#f5f5f5" /></Pressable>
          </View>
        </View>

        {screen === "home" ? (
          <>
            <View style={styles.heroRow}>
              <View><Text style={styles.heroEyebrow}>SUA COLEÇÃO</Text><Text style={styles.heroTitle}>Ouça o que{`\n`}faz sentido.</Text></View>
              <Brand compact />
            </View>
            <View style={styles.searchBox}><Ionicons name="search" size={20} color="#8f8f8f" /><Text style={styles.searchText}>Buscar músicas, artistas e álbuns</Text></View>
            <View style={styles.sectionHeader}><Text style={styles.sectionTitle}>Suas faixas</Text><Text style={styles.sectionLink}>Ver tudo</Text></View>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.trackScroller}>
              {tracks.map((track) => (
                <Pressable key={track.id} style={styles.trackCard} onPress={() => openTrack(track.id)}>
                  <Image source={{ uri: track.cover }} style={styles.trackCover} />
                  <View style={styles.trackCardPlay}><Ionicons name={selectedId === track.id && status.playing ? "pause" : "play"} size={16} color="#111" /></View>
                  <Text style={styles.trackTitle} numberOfLines={1}>{track.title}</Text>
                  <Text style={styles.trackArtist}>{track.artist}</Text>
                </Pressable>
              ))}
            </ScrollView>
            <View style={styles.featureCard}>
              <Image source={{ uri: selected.cover }} style={styles.featureImage} />
              <View style={styles.featureOverlay} />
              <View style={styles.featureCopy}><Text style={styles.featureKicker}>TOCANDO AGORA</Text><Text style={styles.featureTitle}>{selected.title}</Text><Text style={styles.featureArtist}>{selected.artist}</Text></View>
              <Pressable style={styles.featurePlay} onPress={() => (status.playing ? player.pause() : player.play())}><Ionicons name={status.playing ? "pause" : "play"} size={25} color="#111" /></Pressable>
            </View>
            <View style={styles.sectionHeader}><Text style={styles.sectionTitle}>Ouvidos recentemente</Text><Ionicons name="ellipsis-horizontal" size={22} color="#999" /></View>
            {tracks.map((track) => <Pressable key={`recent-${track.id}`} style={styles.recentRow} onPress={() => openTrack(track.id)}><Image source={{ uri: track.cover }} style={styles.recentCover} /><View style={styles.recentInfo}><Text style={styles.recentTitle}>{track.title}</Text><Text style={styles.recentArtist}>{track.artist}</Text></View><Ionicons name="play-circle-outline" size={28} color="#f2f2f2" /></Pressable>)}
          </>
        ) : (
          <View style={styles.settingsPage}>
            <Pressable onPress={() => setScreen("home")} style={styles.backButton}><Ionicons name="arrow-back" size={22} color="#f5f5f5" /><Text style={styles.backText}>Voltar</Text></Pressable>
            <Text style={styles.settingsTitle}>Configurações{`\n`}e privacidade</Text>
            <Text style={styles.settingsSubtitle}>Controle sua conta e sua experiência no app.</Text>
            <View style={styles.settingsCard}><View style={styles.settingRow}><View style={styles.settingIcon}><Ionicons name="lock-closed-outline" size={21} color="#c7ff3d" /></View><View style={styles.settingCopy}><Text style={styles.settingTitle}>Conta privada</Text><Text style={styles.settingDescription}>Somente você pode ver suas playlists.</Text></View><Switch value={privateAccount} onValueChange={setPrivateAccount} trackColor={{ false: "#444", true: "#718e24" }} thumbColor={privateAccount ? "#c7ff3d" : "#aaa"} /></View><View style={styles.divider} /><View style={styles.settingRow}><View style={styles.settingIcon}><Ionicons name="download-outline" size={21} color="#c7ff3d" /></View><View style={styles.settingCopy}><Text style={styles.settingTitle}>Downloads</Text><Text style={styles.settingDescription}>Gerencie músicas disponíveis offline.</Text></View><Ionicons name="chevron-forward" size={19} color="#777" /></View><View style={styles.divider} /><View style={styles.settingRow}><View style={styles.settingIcon}><Ionicons name="shield-checkmark-outline" size={21} color="#c7ff3d" /></View><View style={styles.settingCopy}><Text style={styles.settingTitle}>Privacidade e dados</Text><Text style={styles.settingDescription}>Escolha como seus dados são usados.</Text></View><Ionicons name="chevron-forward" size={19} color="#777" /></View></View>
            <Pressable style={styles.logoutButton} onPress={() => { setLoggedIn(false); setDrawerOpen(false); }}><Ionicons name="log-out-outline" size={20} color="#f26f6f" /><Text style={styles.logoutText}>Sair da conta</Text></Pressable>
          </View>
        )}
      </ScrollView>

      <View style={styles.playerBar}><Image source={{ uri: selected.cover }} style={styles.playerCover} /><View style={styles.playerInfo}><Text style={styles.playerTitle} numberOfLines={1}>{selected.title}</Text><Text style={styles.playerArtist}>{selected.artist}</Text><View style={styles.progressTrack}><View style={[styles.progressValue, { width: `${status.duration ? Math.min(100, (status.currentTime / status.duration) * 100) : 0}%` }]} /></View></View><Pressable onPress={() => (status.playing ? player.pause() : player.play())} style={styles.playerButton}><Ionicons name={status.playing ? "pause" : "play"} size={18} color="#111" /></Pressable><Pressable onPress={nextTrack} style={styles.nextButton}><Ionicons name="play-skip-forward" size={19} color="#f5f5f5" /></Pressable></View>

      <Modal visible={drawerOpen} transparent animationType="slide" onRequestClose={() => setDrawerOpen(false)}>
        <View style={styles.drawerBackdrop}><Pressable style={styles.drawerDismiss} onPress={() => setDrawerOpen(false)} /><View style={styles.drawer}><View style={styles.drawerHandle} /><View style={styles.drawerProfile}><View style={styles.drawerAvatar}><Text style={styles.drawerAvatarText}>S</Text></View><View><Text style={styles.drawerName}>sleep128</Text><Text style={styles.drawerProfileLink}>Ver perfil</Text></View></View><View style={styles.drawerDivider} />{[["add-circle-outline", "Adicionar conta"], ["diamond-outline", "Seu Premium"], ["sparkles-outline", "Novidades"], ["time-outline", "Recentes"], ["megaphone-outline", "Suas atualizações"]].map(([icon, label]) => <Pressable key={label} style={styles.drawerItem} onPress={() => setDrawerOpen(false)}><Ionicons name={icon as keyof typeof Ionicons.glyphMap} size={27} color="#f4f4f4" /><Text style={styles.drawerItemText}>{label}</Text>{label === "Seu Premium" && <Text style={styles.premiumPill}>PREMIUM</Text>}{label === "Suas atualizações" && <View style={styles.updateDot} />}</Pressable>)}<Pressable style={[styles.drawerItem, styles.drawerSettings]} onPress={() => { setDrawerOpen(false); Linking.openURL(ORIGINAL_APP_URL).catch(() => undefined); }}><Ionicons name="settings-outline" size={28} color="#f4f4f4" /><Text style={styles.drawerItemText}>Configurações e privacidade</Text></Pressable><View style={styles.drawerDivider} /><Text style={styles.drawerSection}>MENSAGENS</Text><View style={styles.messageRow}><View style={styles.messageAvatar}><Text style={styles.messageAvatarText}>M</Text></View><View><Text style={styles.messageName}>musicmenu</Text><Text style={styles.messagePreview}>Sua nova coleção está pronta</Text></View></View><Pressable style={styles.newMessage}><Ionicons name="create-outline" size={27} color="#f4f4f4" /><Text style={styles.drawerItemText}>Nova mensagem</Text></Pressable></View></View>
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  app: { flex: 1, backgroundColor: "#101010" },
  scrollContent: { paddingHorizontal: 20, paddingTop: 58, paddingBottom: 132 },
  loginScreen: { flex: 1, backgroundColor: "#101010", overflow: "hidden" },
  loginContent: { flex: 1, paddingHorizontal: 28, paddingTop: 70, paddingBottom: 26, justifyContent: "space-between" },
  loginGlowOne: { position: "absolute", width: 280, height: 280, borderRadius: 140, backgroundColor: "#35451a", opacity: 0.45, top: -140, right: -80 },
  loginGlowTwo: { position: "absolute", width: 240, height: 240, borderRadius: 120, backgroundColor: "#42243c", opacity: 0.5, bottom: 20, left: -140 },
  brandRow: { flexDirection: "row", alignItems: "center", gap: 10 },
  brandMark: { width: 36, height: 36, borderRadius: 12, backgroundColor: "#c7ff3d", alignItems: "center", justifyContent: "center", transform: [{ rotate: "-8deg" }] },
  brandText: { color: "#f8f8f8", fontSize: 23, fontWeight: "800", letterSpacing: -0.8 },
  loginCopy: { marginTop: 36 },
  eyebrow: { color: "#c7ff3d", fontSize: 11, fontWeight: "800", letterSpacing: 2.2, marginBottom: 13 },
  loginTitle: { color: "#fff", fontSize: 48, lineHeight: 51, fontWeight: "800", letterSpacing: -1.7 },
  loginSubtitle: { color: "#a5a5a5", fontSize: 15, lineHeight: 22, marginTop: 18, maxWidth: 315 },
  form: { marginTop: 10 },
  inputLabel: { color: "#e8e8e8", fontSize: 12, fontWeight: "700", marginBottom: 8 },
  input: { height: 54, backgroundColor: "#1d1d1d", borderWidth: 1, borderColor: "#333", borderRadius: 14, color: "#fff", paddingHorizontal: 16, fontSize: 15, marginBottom: 17 },
  passwordLabelRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  mutedSmall: { color: "#777", fontSize: 11, marginBottom: 8 },
  passwordInputWrap: { height: 54, backgroundColor: "#1d1d1d", borderWidth: 1, borderColor: "#333", borderRadius: 14, flexDirection: "row", alignItems: "center", paddingHorizontal: 16 },
  passwordInput: { flex: 1, color: "#fff", fontSize: 15 },
  errorText: { color: "#f07979", fontSize: 12, marginTop: 8 },
  primaryButton: { height: 55, marginTop: 22, backgroundColor: "#c7ff3d", borderRadius: 15, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 12 },
  primaryButtonText: { color: "#111", fontSize: 16, fontWeight: "800" },
  demoButton: { alignItems: "center", marginTop: 17, padding: 8 },
  demoButtonText: { color: "#a9a9a9", fontSize: 13, fontWeight: "600" },
  loginFooter: { color: "#686868", textAlign: "center", fontSize: 11, lineHeight: 17, paddingHorizontal: 20 },
  topBar: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", marginBottom: 29 },
  avatarButton: { flexDirection: "row", alignItems: "center", gap: 10 },
  avatar: { width: 43, height: 43, borderRadius: 22, backgroundColor: "#bd7d9a", alignItems: "center", justifyContent: "center" },
  avatarText: { color: "#fff", fontWeight: "800", fontSize: 19 },
  greeting: { color: "#8f8f8f", fontSize: 11, marginBottom: 2 },
  userName: { color: "#fff", fontSize: 16, fontWeight: "700" },
  topActions: { flexDirection: "row", gap: 8 },
  circleButton: { width: 38, height: 38, borderRadius: 19, backgroundColor: "#1d1d1d", alignItems: "center", justifyContent: "center" },
  heroRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 24 },
  heroEyebrow: { color: "#c7ff3d", fontSize: 11, fontWeight: "800", letterSpacing: 1.8, marginBottom: 10 },
  heroTitle: { color: "#fff", fontSize: 35, lineHeight: 37, fontWeight: "800", letterSpacing: -1.2 },
  searchBox: { height: 52, borderRadius: 15, backgroundColor: "#1d1d1d", flexDirection: "row", alignItems: "center", paddingHorizontal: 16, gap: 11, marginBottom: 31 },
  searchText: { color: "#777", fontSize: 13 },
  sectionHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 15, marginTop: 2 },
  sectionTitle: { color: "#f4f4f4", fontSize: 19, fontWeight: "800", letterSpacing: -0.3 },
  sectionLink: { color: "#c7ff3d", fontSize: 12, fontWeight: "700" },
  trackScroller: { gap: 15, paddingBottom: 28 },
  trackCard: { width: 146, position: "relative" },
  trackCover: { width: 146, height: 146, borderRadius: 12, backgroundColor: "#303030" },
  trackCardPlay: { position: "absolute", right: 10, top: 111, width: 35, height: 35, borderRadius: 18, backgroundColor: "#c7ff3d", alignItems: "center", justifyContent: "center" },
  trackTitle: { color: "#f6f6f6", fontSize: 13, fontWeight: "700", marginTop: 11 },
  trackArtist: { color: "#858585", fontSize: 12, marginTop: 4 },
  featureCard: { height: 206, borderRadius: 18, overflow: "hidden", marginBottom: 29, backgroundColor: "#282828" },
  featureImage: { width: "100%", height: "100%", position: "absolute" },
  featureOverlay: { ...StyleSheet.absoluteFill, backgroundColor: "rgba(0,0,0,0.48)" },
  featureCopy: { position: "absolute", left: 18, bottom: 20 },
  featureKicker: { color: "#c7ff3d", fontSize: 10, fontWeight: "800", letterSpacing: 1.6, marginBottom: 7 },
  featureTitle: { color: "#fff", fontSize: 22, fontWeight: "800", maxWidth: 235 },
  featureArtist: { color: "#d0d0d0", fontSize: 13, marginTop: 4 },
  featurePlay: { position: "absolute", bottom: 19, right: 18, width: 54, height: 54, borderRadius: 27, backgroundColor: "#c7ff3d", alignItems: "center", justifyContent: "center" },
  recentRow: { flexDirection: "row", alignItems: "center", gap: 12, paddingVertical: 9 },
  recentCover: { width: 52, height: 52, borderRadius: 8, backgroundColor: "#333" },
  recentInfo: { flex: 1 },
  recentTitle: { color: "#eee", fontSize: 14, fontWeight: "700" },
  recentArtist: { color: "#858585", fontSize: 12, marginTop: 5 },
  playerBar: { position: "absolute", left: 12, right: 12, bottom: 14, minHeight: 71, borderRadius: 18, backgroundColor: "#242424", borderWidth: 1, borderColor: "#383838", padding: 9, flexDirection: "row", alignItems: "center", gap: 10 },
  playerCover: { width: 52, height: 52, borderRadius: 11 },
  playerInfo: { flex: 1 },
  playerTitle: { color: "#f3f3f3", fontSize: 12, fontWeight: "700" },
  playerArtist: { color: "#858585", fontSize: 11, marginTop: 3, marginBottom: 7 },
  progressTrack: { height: 3, borderRadius: 3, backgroundColor: "#4a4a4a", overflow: "hidden" },
  progressValue: { height: 3, backgroundColor: "#c7ff3d" },
  playerButton: { width: 36, height: 36, borderRadius: 18, backgroundColor: "#c7ff3d", alignItems: "center", justifyContent: "center" },
  nextButton: { width: 28, alignItems: "center" },
  drawerBackdrop: { flex: 1, flexDirection: "row", backgroundColor: "rgba(0,0,0,0.54)" },
  drawerDismiss: { flex: 1 },
  drawer: { width: "86%", backgroundColor: "#202020", paddingHorizontal: 26, paddingTop: 58, paddingBottom: 25, shadowColor: "#000", shadowOpacity: 0.5, shadowRadius: 22, elevation: 12 },
  drawerHandle: { alignSelf: "center", width: 36, height: 4, borderRadius: 3, backgroundColor: "#666", marginBottom: 30 },
  drawerProfile: { flexDirection: "row", alignItems: "center", gap: 15, marginBottom: 23 },
  drawerAvatar: { width: 62, height: 62, borderRadius: 31, backgroundColor: "#bd7d9a", alignItems: "center", justifyContent: "center" },
  drawerAvatarText: { color: "#fff", fontWeight: "800", fontSize: 28 },
  drawerName: { color: "#f6f6f6", fontSize: 19, fontWeight: "800" },
  drawerProfileLink: { color: "#aaa", fontSize: 14, marginTop: 5 },
  drawerDivider: { height: 1, backgroundColor: "#3a3a3a", marginVertical: 15 },
  drawerItem: { height: 57, flexDirection: "row", alignItems: "center", gap: 20, position: "relative" },
  drawerSettings: { marginTop: 7 },
  drawerItemText: { color: "#f2f2f2", fontSize: 16, fontWeight: "600", flex: 1 },
  premiumPill: { color: "#171717", backgroundColor: "#f1b4cb", fontSize: 9, fontWeight: "900", paddingHorizontal: 10, paddingVertical: 6, borderRadius: 7 },
  updateDot: { width: 9, height: 9, borderRadius: 5, backgroundColor: "#278bff", marginRight: 4 },
  drawerSection: { color: "#f1f1f1", fontSize: 18, fontWeight: "900", marginBottom: 12, letterSpacing: 0.3 },
  messageRow: { flexDirection: "row", alignItems: "center", gap: 12, marginBottom: 16 },
  messageAvatar: { width: 44, height: 44, borderRadius: 22, backgroundColor: "#66485a", alignItems: "center", justifyContent: "center" },
  messageAvatarText: { color: "#fff", fontSize: 17, fontWeight: "800" },
  messageName: { color: "#eee", fontSize: 14, fontWeight: "700" },
  messagePreview: { color: "#999", fontSize: 12, marginTop: 4 },
  newMessage: { flexDirection: "row", alignItems: "center", gap: 20, paddingVertical: 15 },
  settingsPage: { paddingTop: 10 },
  backButton: { flexDirection: "row", alignItems: "center", gap: 8, marginBottom: 35 },
  backText: { color: "#ddd", fontSize: 14, fontWeight: "700" },
  settingsTitle: { color: "#fff", fontSize: 38, lineHeight: 40, fontWeight: "800", letterSpacing: -1 },
  settingsSubtitle: { color: "#929292", fontSize: 14, lineHeight: 21, marginTop: 13, marginBottom: 28 },
  settingsCard: { backgroundColor: "#1d1d1d", borderRadius: 17, paddingHorizontal: 16 },
  settingRow: { minHeight: 82, flexDirection: "row", alignItems: "center", gap: 13 },
  settingIcon: { width: 40, height: 40, borderRadius: 13, backgroundColor: "#303c18", alignItems: "center", justifyContent: "center" },
  settingCopy: { flex: 1 },
  settingTitle: { color: "#f2f2f2", fontSize: 14, fontWeight: "700" },
  settingDescription: { color: "#888", fontSize: 11, marginTop: 4 },
  divider: { height: 1, backgroundColor: "#343434" },
  logoutButton: { flexDirection: "row", alignItems: "center", gap: 12, marginTop: 24, padding: 8 },
  logoutText: { color: "#f07979", fontSize: 14, fontWeight: "700" },
});
