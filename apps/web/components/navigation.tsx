"use client"

import Link from "next/link"
import Image from "next/image"
import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Menu, X, Sun, Moon, ArrowRight, User, LogOut, LayoutDashboard } from "lucide-react"
import { useTheme } from "next-themes"
import { getSupabaseBrowserClient } from "@/lib/supabase"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
  DropdownMenuLabel,
} from "@/components/ui/dropdown-menu"

export function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)
  const { theme, setTheme } = useTheme()
  const [isSignedIn, setIsSignedIn] = useState(false)
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 1045) {
        setIsMenuOpen(false)
      }
    }

    window.addEventListener("resize", handleResize)
    return () => window.removeEventListener("resize", handleResize)
  }, [])

  useEffect(() => {
    setMounted(true)
    const supabase = getSupabaseBrowserClient()

    supabase.auth.getSession().then(({ data }) => {
      setIsSignedIn(!!data.session)
    })

    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      setIsSignedIn(!!session)
    })

    const handleClickOutside = (event: MouseEvent) => {
      const nav = document.getElementById("mobile-nav")
      const button = document.getElementById("mobile-menu-button")

      if (
        isMenuOpen &&
        nav &&
        button &&
        !nav.contains(event.target as Node) &&
        !button.contains(event.target as Node)
      ) {
        setIsMenuOpen(false)
      }
    }

    if (isMenuOpen) {
      document.addEventListener("mousedown", handleClickOutside)
    }

    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
      sub.subscription.unsubscribe()
    }
  }, [isMenuOpen])

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 0)
    }

    handleScroll()
    window.addEventListener("scroll", handleScroll)

    return () => {
      window.removeEventListener("scroll", handleScroll)
    }
  }, [])


  return (
    <nav className="sticky top-4 z-50 w-full">
      <div className="w-full max-w-[1385px] mx-auto px-4 min-[1045px]:px-6">
        <div
          className={`w-full rounded-2xl bg-background/80 backdrop-blur-md transition-all ${scrolled ? "border border-border shadow-md" : "border border-transparent shadow-none"
            }`}
        >
          <div className="grid grid-cols-[auto_1fr_auto] h-14 items-center px-4 min-[1045px]:px-6">
            {/* Logo and App Name */}
            <div className="flex items-center space-x-3 justify-self-start">
              {/* light icon */}
              <Image
                src="/icon-light.png"
                alt="CAPlayground icon"
                width={32}
                height={32}
                className="rounded-lg block dark:hidden"
                priority
              />
              {/* dark icon */}
              <Image
                src="/icon-dark.png"
                alt="CAPlayground icon"
                width={32}
                height={32}
                className="rounded-lg hidden dark:block"
              />
              <Link
                href="/"
                className="font-helvetica-neue text-xl font-bold text-foreground hover:text-accent transition-colors"
                onClick={() => setIsMenuOpen(false)}
              >
                CAPlayground
              </Link>
            </div>

            {/* Desktop Navigation */}
            <div className="hidden min-[1045px]:flex items-center justify-center gap-6 justify-self-center">
              <Link href="/docs" className="text-foreground hover:text-accent transition-colors">
                Docs
              </Link>
              <Link href="/contributors" className="text-foreground hover:text-accent transition-colors">
                Contributors
              </Link>
              <Link href="/roadmap" className="text-foreground hover:text-accent transition-colors">
                Roadmap
              </Link>
              <Link href="/wallpapers" className="text-foreground hover:text-accent transition-colors">
                Wallpapers
              </Link>
            </div>

            {/* Right actions */}
            <div className="hidden min-[1045px]:flex items-center gap-4 justify-self-end">
              {isSignedIn ? (
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button
                      variant="ghost"
                      size="icon"
                      aria-label="Account"
                      className="rounded-full h-9 w-9 p-0"
                    >
                      <User className="h-5 w-5" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="w-40">
                    <DropdownMenuItem onClick={() => (window.location.href = "/dashboard")}>
                      <LayoutDashboard className="mr-2 h-4 w-4" /> Dashboard
                    </DropdownMenuItem>
                    <DropdownMenuItem
                      onClick={async () => {
                        const supabase = getSupabaseBrowserClient()
                        await fetch('/api/auth/signout', { method: 'POST' })
                        await supabase.auth.signOut()
                        window.location.href = "/"
                      }}
                    >
                      <LogOut className="mr-2 h-4 w-4" /> Sign out
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              ) : (
                <Link href="/signin">
                  <Button variant="outline" className="font-semibold">
                    Sign In
                  </Button>
                </Link>
              )}
              <Link href="/projects">
                <Button variant="default" className="bg-accent hover:bg-accent/90 text-accent-foreground font-semibold">
                  Projects <ArrowRight className="h-4 w-4 ml-2" />
                </Button>
              </Link>

              <Button
                variant="ghost"
                size="icon"
                aria-label="Toggle theme"
                onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
                className="rounded-full h-9 w-9 p-0"
              >
                {mounted && theme === "dark" ? (
                  <Sun className="h-5 w-5" />
                ) : (
                  <Moon className="h-5 w-5" />
                )}
              </Button>
            </div>

            {/* Mobile Menu Button */}
            <button
              id="mobile-menu-button"
              className="min-[1045px]:hidden p-3 rounded-lg hover:bg-muted transition-all justify-self-end touch-target-min ios-active-scale"
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              aria-label="Toggle menu"
              /* eslint-disable-next-line */
              aria-expanded={isMenuOpen}
            >
              {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>

          <div
            id="mobile-nav"
            className={`overflow-hidden transition-all duration-300 ease-in-out ${isMenuOpen ? "max-h-[600px] opacity-100" : "max-h-0 opacity-0"
              }`}
          >
            <div className="ios-inset-group mx-4 my-2 border-none">
              <div className="flex flex-col">
                <Link
                  href="/docs"
                  className="ios-list-item ios-active-scale transition-all"
                  onClick={() => setIsMenuOpen(false)}
                >
                  <span className="text-[17px] font-medium">Docs</span>
                  <ArrowRight className="h-4 w-4 text-muted-foreground/50" />
                </Link>
                <Link
                  href="/roadmap"
                  className="ios-list-item ios-active-scale transition-all"
                  onClick={() => setIsMenuOpen(false)}
                >
                  <span className="text-[17px] font-medium">Roadmap</span>
                  <ArrowRight className="h-4 w-4 text-muted-foreground/50" />
                </Link>
                <Link
                  href="/wallpapers"
                  className="ios-list-item ios-active-scale transition-all"
                  onClick={() => setIsMenuOpen(false)}
                >
                  <span className="text-[17px] font-medium">Wallpapers</span>
                  <ArrowRight className="h-4 w-4 text-muted-foreground/50" />
                </Link>
                <Link
                  href="/contributors"
                  className="ios-list-item ios-active-scale transition-all"
                  onClick={() => setIsMenuOpen(false)}
                >
                  <span className="text-[17px] font-medium">Contributors</span>
                  <ArrowRight className="h-4 w-4 text-muted-foreground/50" />
                </Link>
              </div>
            </div>

            <div className="ios-inset-group mx-4 mb-4 border-none">
              <div className="flex flex-col">
                {isSignedIn ? (
                  <Link
                    href="/dashboard"
                    className="ios-list-item ios-active-scale transition-all"
                    onClick={() => setIsMenuOpen(false)}
                  >
                    <span className="text-[17px] font-medium">Dashboard</span>
                    <LayoutDashboard className="h-4 w-4 text-ios-blue" />
                  </Link>
                ) : (
                  <Link
                    href="/signin"
                    className="ios-list-item ios-active-scale transition-all"
                    onClick={() => setIsMenuOpen(false)}
                  >
                    <span className="text-[17px] font-medium text-ios-blue">Sign In</span>
                  </Link>
                )}
                <Link
                  href="/projects"
                  className="ios-list-item ios-active-scale transition-all"
                  onClick={() => setIsMenuOpen(false)}
                >
                  <span className="text-[17px] font-medium">Projects</span>
                  <Button variant="ghost" size="sm" className="h-auto p-0 text-ios-blue">
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
                <button
                  className="ios-list-item ios-active-scale transition-all"
                  onClick={() => {
                    setTheme(theme === "dark" ? "light" : "dark")
                    setIsMenuOpen(false)
                  }}
                >
                  <span className="text-[17px] font-medium">
                    {theme === "dark" ? "Light Mode" : "Dark Mode"}
                  </span>
                  {theme === "dark" ? (
                    <Sun className="h-5 w-5 text-orange-400" />
                  ) : (
                    <Moon className="h-5 w-5 text-ios-blue" />
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>
  )
}
