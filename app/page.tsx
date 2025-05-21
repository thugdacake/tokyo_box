"use client"

import { useState, useEffect, useRef } from "react"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Slider } from "@/components/ui/slider"
import { Search, PlayCircle, SkipBack, SkipForward, Volume2, Plus, X, Music, ListMusic, Heart, Settings, Maximize2, Minimize2, Pause } from 'lucide-react'
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { toast } from "@/components/ui/use-toast"

export default function TokyoBoxUI() {
  const [isExpanded, setIsExpanded] = useState(false)
  const [scale, setScale] = useState(1)
  const [currentTab, setCurrentTab] = useState("search")
  const [searchQuery, setSearchQuery] = useState("")
  const [volume, setVolume] = useState(50)
  const [isPlaying, setIsPlaying] = useState(false)
  const [currentTrack, setCurrentTrack] = useState(null)
  const [searchResults, setSearchResults] = useState([])
  const [playlists, setPlaylists] = useState([])
  const [favorites, setFavorites] = useState([])
  const [isLoading, setIsLoading] = useState(false)

  // Refs for scrollable containers
  const searchContainerRef = useRef(null)
  const playlistsContainerRef = useRef(null)
  const favoritesContainerRef = useRef(null)

  // Mock data for demonstration
  const mockSearchResults = Array(10)
    .fill(null)
    .map((_, i) => ({
      id: `track-${i}`,
      videoId: `video-${i}`,
      title: `Nome da Música ${i + 1}`,
      artist: `Nome do Artista ${i + 1}`,
      thumbnailUrl: "/placeholder.svg?height=120&width=120",
    }))

  const mockPlaylists = Array(7)
    .fill(null)
    .map((_, i) => ({
      id: i + 1,
      name: `Playlist ${i + 1}`,
      trackCount: (i + 1) * 5,
      coverUrl: "/placeholder.svg?height=40&width=40",
    }))

  const mockFavorites = Array(8)
    .fill(null)
    .map((_, i) => ({
      id: i + 1,
      videoId: `video-${i}`,
      title: `Música Favorita ${i + 1}`,
      artist: `Artista ${i + 1}`,
      thumbnailUrl: "/placeholder.svg?height=40&width=40",
    }))

  // Simulate backend communication
  useEffect(() => {
    // Load initial data
    setSearchResults(mockSearchResults)
    setPlaylists(mockPlaylists)
    setFavorites(mockFavorites)

    // Setup message listener for NUI messages from Lua
    const handleMessage = (event) => {
      const data = event.data

      if (!data || !data.type) return

      switch (data.type) {
        case "openUI":
          // Update state with settings from backend
          if (data.settings) {
            setVolume(data.settings.volume || 50)
            setScale(data.settings.uiScale || 1)
            setIsExpanded(data.settings.isExpanded || false)
          }

          // Update state with current data
          if (data.state) {
            setIsPlaying(data.state.isPlaying || false)
            setCurrentTrack(data.state.currentTrack || null)
            // We would update playlists and favorites here too
          }
          break

        case "updateSearchResults":
          setSearchResults(data.results || [])
          setIsLoading(false)
          break

        case "updatePlayer":
          setIsPlaying(data.isPlaying || false)
          setCurrentTrack(data.track || null)
          break

        case "playlists":
          setPlaylists(data.playlists || [])
          break

        case "receiveFavorites":
          setFavorites(data.favorites || [])
          break
      }
    }

    window.addEventListener("message", handleMessage)

    return () => {
      window.removeEventListener("message", handleMessage)
    }
  }, [])

  // Function to send messages to Lua backend
  const sendMessage = (type, data = {}) => {
    // In a real implementation, this would use fetch to communicate with the Lua backend
    console.log("Sending message to backend:", type, data)

    // Simulate backend response for demo purposes
    if (type === "searchVideo") {
      setIsLoading(true)
      setTimeout(() => {
        setIsLoading(false)
        // We'd normally get this from the backend
        setSearchResults(mockSearchResults)
        toast({
          title: "Busca concluída",
          description: `Encontrados ${mockSearchResults.length} resultados para "${data.query}"`,
        })
      }, 1000)
    }

    if (type === "playVideo") {
      const track = mockSearchResults.find((t) => t.videoId === data.videoId)
      if (track) {
        setCurrentTrack(track)
        setIsPlaying(true)
        toast({
          title: "Reproduzindo",
          description: `${track.title} - ${track.artist}`,
        })
      }
    }

    if (type === "stopVideo") {
      setIsPlaying(false)
      toast({
        title: "Reprodução parada",
        description: "A música foi interrompida",
      })
    }

    if (type === "setVolume") {
      setVolume(data.volume)
    }

    if (type === "updateUISettings") {
      if (data.scale !== undefined) {
        setScale(data.scale)
      }
      if (data.isExpanded !== undefined) {
        setIsExpanded(data.isExpanded)
      }
      toast({
        title: "Configurações salvas",
        description: "As configurações da interface foram atualizadas",
      })
    }

    if (type === "addFavorite") {
      toast({
        title: "Adicionado aos favoritos",
        description: "A música foi adicionada aos seus favoritos",
      })
    }

    if (type === "addToPlaylist") {
      toast({
        title: "Adicionado à playlist",
        description: `Música adicionada à playlist "${data.playlistName}"`,
      })
    }

    // In a real implementation:
    // fetch(`https://${GetParentResourceName()}/${type}`, {
    //   method: "POST",
    //   headers: { "Content-Type": "application/json" },
    //   body: JSON.stringify(data)
    // }).catch(error => console.error("Error sending message:", error))
  }

  // Handle search
  const handleSearch = () => {
    if (!searchQuery.trim()) return
    sendMessage("searchVideo", { query: searchQuery })
  }

  // Handle play/pause
  const togglePlayback = (videoId) => {
    if (isPlaying) {
      sendMessage("stopVideo")
    } else {
      sendMessage("playVideo", { videoId: videoId || currentTrack?.videoId })
    }
  }

  // Handle volume change
  const handleVolumeChange = (values) => {
    const newVolume = values[0]
    setVolume(newVolume)
    sendMessage("setVolume", { volume: newVolume })
  }

  // Handle UI settings change
  const handleScaleChange = (values) => {
    const newScale = values[0]
    setScale(newScale)
    sendMessage("updateUISettings", { scale: newScale })
  }

  const handleExpandToggle = (expanded) => {
    setIsExpanded(expanded)
    sendMessage("updateUISettings", { isExpanded: expanded })
  }

  // Handle close button
  const handleClose = () => {
    sendMessage("closeUI")
  }

  // Handle add to favorites
  const handleAddToFavorites = (videoId) => {
    sendMessage("addFavorite", { videoId })
  }

  // Handle add to playlist
  const handleAddToPlaylist = (videoId) => {
    // In a real implementation, this would open a modal to select a playlist
    // For now, we'll just simulate adding to the first playlist
    if (playlists.length > 0) {
      sendMessage("addToPlaylist", { videoId, playlistId: playlists[0].id, playlistName: playlists[0].name })
    } else {
      toast({
        title: "Nenhuma playlist disponível",
        description: "Crie uma playlist primeiro",
        variant: "destructive",
      })
    }
  }

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col items-end">
      {/* Scale settings popover */}
      <Popover>
        <PopoverTrigger asChild>
          <Button variant="outline" size="icon" className="rounded-full bg-black/80 border-white/10 text-white mb-2">
            <Settings className="h-4 w-4" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-80 bg-[rgba(40,40,40,0.95)] border-white/10 text-white">
          <div className="space-y-4">
            <h4 className="font-medium">Configurações</h4>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label htmlFor="ui-scale">Escala da Interface</Label>
                <span className="text-sm text-gray-400">{Math.round(scale * 100)}%</span>
              </div>
              <Slider id="ui-scale" min={0.7} max={1.3} step={0.05} value={[scale]} onValueChange={handleScaleChange} />
            </div>

            <div className="flex items-center space-x-2">
              <Switch id="expanded" checked={isExpanded} onCheckedChange={handleExpandToggle} />
              <Label htmlFor="expanded">Modo expandido</Label>
            </div>
          </div>
        </PopoverContent>
      </Popover>

      {/* iPhone style interface */}
      <div
        className="overflow-hidden rounded-3xl bg-black shadow-lg transition-all duration-300"
        style={{
          transform: `scale(${scale})`,
          transformOrigin: "bottom right",
          width: isExpanded ? "320px" : "280px",
          height: isExpanded ? "580px" : "480px",
        }}
      >
        {/* Status bar */}
        <div className="flex justify-between items-center px-4 py-1 bg-black">
          <div className="text-white text-xs">9:41</div>
          <div className="flex items-center space-x-1">
            <div className="text-white text-xs">
              <Image src="/placeholder.svg?height=16&width=16" width={16} height={16} alt="Signal" />
            </div>
            <div className="text-white text-xs">
              <Image src="/placeholder.svg?height=16&width=16" width={16} height={16} alt="Wifi" />
            </div>
            <div className="text-white text-xs">
              <Image src="/placeholder.svg?height=16&width=16" width={16} height={16} alt="Battery" />
            </div>
          </div>
        </div>

        {/* App content */}
        <div className="flex flex-col h-full bg-[rgb(18,18,18)] text-white">
          {/* Header */}
          <header className="flex justify-between items-center p-3 bg-[rgba(40,40,40,0.5)]">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-gradient-to-br from-[#1DB954] to-[#169C46] rounded-xl flex items-center justify-center">
                <Music className="w-5 h-5 text-white" />
              </div>
              <h1 className="text-lg font-medium">Tokyo Box</h1>
            </div>
            <div className="flex gap-1">
              <Button
                variant="ghost"
                size="icon"
                className="rounded-full h-8 w-8"
                onClick={() => handleExpandToggle(!isExpanded)}
              >
                {isExpanded ? <Minimize2 className="w-4 h-4" /> : <Maximize2 className="w-4 h-4" />}
              </Button>
              <Button variant="ghost" size="icon" className="rounded-full h-8 w-8" onClick={handleClose}>
                <X className="w-4 h-4" />
              </Button>
            </div>
          </header>

          {/* Main content */}
          <Tabs defaultValue="search" value={currentTab} onValueChange={setCurrentTab} className="flex-1 flex flex-col">
            <TabsContent
              value="search"
              className="flex-1 overflow-y-auto p-3 space-y-3 h-full"
              ref={searchContainerRef}
            >
              <div className="flex gap-2">
                <Input
                  type="text"
                  placeholder="Buscar músicas..."
                  className="bg-[rgba(40,40,40,0.8)] border-white/10 rounded-full"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  onKeyPress={(e) => e.key === "Enter" && handleSearch()}
                />
                <Button
                  size="icon"
                  className="bg-[#1DB954] hover:bg-[#1AA34A] rounded-full"
                  onClick={handleSearch}
                  disabled={isLoading}
                >
                  <Search className="w-4 h-4" />
                </Button>
              </div>

              {isLoading ? (
                <div className="flex justify-center items-center py-8">
                  <div className="w-6 h-6 border-2 border-t-2 border-[#1DB954] rounded-full animate-spin"></div>
                </div>
              ) : (
                <div className="grid grid-cols-2 gap-2 pb-4">
                  {searchResults.map((item, index) => (
                    <div key={index} className="bg-[rgba(40,40,40,0.8)] rounded-lg overflow-hidden">
                      <Image
                        src={item.thumbnailUrl || "/placeholder.svg?height=120&width=120"}
                        width={120}
                        height={120}
                        alt="Thumbnail"
                        className="w-full aspect-square object-cover"
                      />
                      <div className="p-2">
                        <h3 className="font-medium text-xs truncate">{item.title}</h3>
                        <p className="text-xs text-gray-400 truncate">{item.artist}</p>
                        <div className="flex justify-end gap-1 mt-1">
                          <Button
                            variant="ghost"
                            size="icon"
                            className="rounded-full h-6 w-6"
                            onClick={() => togglePlayback(item.videoId)}
                          >
                            <PlayCircle className="w-4 h-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="rounded-full h-6 w-6"
                            onClick={() => handleAddToPlaylist(item.videoId)}
                          >
                            <Plus className="w-4 h-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="rounded-full h-6 w-6"
                            onClick={() => handleAddToFavorites(item.videoId)}
                          >
                            <Heart className="w-4 h-4" />
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </TabsContent>

            <TabsContent value="playlists" className="flex-1 overflow-y-auto p-3 h-full" ref={playlistsContainerRef}>
              <div className="flex justify-between items-center mb-3">
                <h2 className="text-base font-medium">Suas Playlists</h2>
                <Button size="sm" className="bg-[#1DB954] hover:bg-[#1AA34A] rounded-full">
                  <Plus className="w-4 h-4 mr-1" /> Criar
                </Button>
              </div>

              <div className="space-y-2 pb-4">
                {playlists.map((playlist) => (
                  <div key={playlist.id} className="flex items-center p-2 bg-[rgba(40,40,40,0.8)] rounded-lg">
                    <Image
                      src={playlist.coverUrl || "/placeholder.svg?height=40&width=40"}
                      width={40}
                      height={40}
                      alt="Playlist"
                      className="rounded-md mr-2"
                    />
                    <div>
                      <h3 className="font-medium text-sm">{playlist.name}</h3>
                      <p className="text-xs text-gray-400">{playlist.trackCount} músicas</p>
                    </div>
                  </div>
                ))}
              </div>
            </TabsContent>

            <TabsContent value="favorites" className="flex-1 overflow-y-auto p-3 h-full" ref={favoritesContainerRef}>
              <h2 className="text-base font-medium mb-3">Músicas Favoritas</h2>

              <div className="space-y-2 pb-4">
                {favorites.map((favorite) => (
                  <div key={favorite.id} className="flex items-center p-2 bg-[rgba(40,40,40,0.8)] rounded-lg">
                    <Image
                      src={favorite.thumbnailUrl || "/placeholder.svg?height=40&width=40"}
                      width={40}
                      height={40}
                      alt="Cover"
                      className="rounded-md mr-2"
                    />
                    <div className="flex-1 min-w-0">
                      <h3 className="font-medium text-sm truncate">{favorite.title}</h3>
                      <p className="text-xs text-gray-400 truncate">{favorite.artist}</p>
                    </div>
                    <Button
                      variant="ghost"
                      size="icon"
                      className="rounded-full h-6 w-6"
                      onClick={() => togglePlayback(favorite.videoId)}
                    >
                      <PlayCircle className="w-4 h-4" />
                    </Button>
                  </div>
                ))}
              </div>
            </TabsContent>

            {/* Player */}
            <div className="bg-[rgba(40,40,40,0.7)] backdrop-blur-md p-3 border-t border-white/5">
              <div className="flex items-center gap-2 mb-2">
                <Image
                  src={currentTrack?.thumbnailUrl || "/placeholder.svg?height=42&width=42"}
                  width={42}
                  height={42}
                  alt="Capa"
                  className="rounded-md"
                />
                <div className="flex-1 min-w-0">
                  <h3 className="font-medium text-sm truncate">{currentTrack?.title || "Nenhuma música tocando"}</h3>
                  <p className="text-xs text-gray-400 truncate">{currentTrack?.artist || "Selecione uma música"}</p>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <Button variant="ghost" size="icon" className="rounded-full" disabled>
                  <SkipBack className="w-4 h-4" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  className="rounded-full h-10 w-10"
                  onClick={() => togglePlayback()}
                  disabled={!currentTrack}
                >
                  {isPlaying ? <Pause className="w-6 h-6" /> : <PlayCircle className="w-6 h-6" />}
                </Button>
                <Button variant="ghost" size="icon" className="rounded-full" disabled>
                  <SkipForward className="w-4 h-4" />
                </Button>
              </div>

              <div className="flex items-center gap-2 mt-2">
                <Volume2 className="w-4 h-4 text-gray-400" />
                <Slider value={[volume]} max={100} step={1} className="h-1" onValueChange={handleVolumeChange} />
              </div>
            </div>

            {/* Tab bar */}
            <TabsList className="bg-[rgba(20,20,20,0.9)] backdrop-blur-md border-t border-white/5 p-1 grid grid-cols-3 h-16 rounded-none">
              <TabsTrigger
                value="search"
                className="flex flex-col items-center justify-center rounded-xl data-[state=active]:bg-[rgba(80,80,80,0.3)] h-full"
              >
                <Search className="w-5 h-5" />
                <span className="text-xs mt-1">Buscar</span>
              </TabsTrigger>
              <TabsTrigger
                value="playlists"
                className="flex flex-col items-center justify-center rounded-xl data-[state=active]:bg-[rgba(80,80,80,0.3)] h-full"
              >
                <ListMusic className="w-5 h-5" />
                <span className="text-xs mt-1">Playlists</span>
              </TabsTrigger>
              <TabsTrigger
                value="favorites"
                className="flex flex-col items-center justify-center rounded-xl data-[state=active]:bg-[rgba(80,80,80,0.3)] h-full"
              >
                <Heart className="w-5 h-5" />
                <span className="text-xs mt-1">Favoritos</span>
              </TabsTrigger>
            </TabsList>
          </Tabs>
        </div>
      </div>
    </div>
  )
}
