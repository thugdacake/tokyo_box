"use client"

import type React from "react"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"

export function PlaylistModal() {
  const [open, setOpen] = useState(false)
  const [playlistName, setPlaylistName] = useState("")
  const [coverUrl, setCoverUrl] = useState("")

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // Aqui você enviaria os dados para o backend
    console.log({ playlistName, coverUrl })
    setOpen(false)
    setPlaylistName("")
    setCoverUrl("")
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <Button onClick={() => setOpen(true)} className="bg-[#1DB954] hover:bg-[#1AA34A] flex items-center gap-2">
        <span className="sr-only sm:not-sr-only">Criar Playlist</span>
      </Button>
      <DialogContent className="bg-[rgba(40,40,40,0.95)] border-white/10 text-white">
        <DialogHeader>
          <DialogTitle>Criar Playlist</DialogTitle>
          <DialogDescription className="text-gray-400">
            Crie uma nova playlist para organizar suas músicas favoritas.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label htmlFor="name">Nome da Playlist</Label>
              <Input
                id="name"
                value={playlistName}
                onChange={(e) => setPlaylistName(e.target.value)}
                className="bg-[rgba(18,18,18,0.95)] border-white/10"
                required
                minLength={3}
                maxLength={50}
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="cover">Capa (opcional)</Label>
              <Input
                id="cover"
                value={coverUrl}
                onChange={(e) => setCoverUrl(e.target.value)}
                placeholder="URL da imagem"
                className="bg-[rgba(18,18,18,0.95)] border-white/10"
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => setOpen(false)}>
              Cancelar
            </Button>
            <Button type="submit" className="bg-[#1DB954] hover:bg-[#1AA34A]">
              Criar
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
