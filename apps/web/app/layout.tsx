import type React from "react"
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { ThemeProvider } from "@/components/theme-provider"
import { Favicon } from "@/components/favicon"
import UnofficialDomainBanner from "@/components/unofficial-domain-banner"
import { PostHogProvider } from "@/components/posthog-provider"

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
})

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'),
  title: "CAPlayground - CA Wallpaper Editor",
  description: "Create beautiful animated wallpapers for iOS and iPadOS on any desktop computer",
  verification: {
    google: "5CfgPBQMN4wnoC3Va9OnlfALRYaoLEekJkqMkGKLXOc",
  },
  openGraph: {
    title: "CAPlayground - CA Wallpaper Editor",
    description: "Create beautiful animated wallpapers for iOS and iPadOS on any desktop computer",
    type: "website",
    images: [
      { url: "/icon-light.png", alt: "CAPlayground icon (light)" },
      { url: "/icon-dark.png", alt: "CAPlayground icon (dark)" },
    ],
  },
  icons: {
    icon: [
      { url: "/icon-light.png", media: "(prefers-color-scheme: light)" },
      { url: "/icon-dark.png", media: "(prefers-color-scheme: dark)" },
    ],
    apple: [
      { url: "/icon-light.png", media: "(prefers-color-scheme: light)" },
      { url: "/icon-dark.png", media: "(prefers-color-scheme: dark)" },
    ],
    shortcut: [
      { url: "/icon-light.png", media: "(prefers-color-scheme: light)" },
      { url: "/icon-dark.png", media: "(prefers-color-scheme: dark)" },
    ],
  },
  viewport: {
    width: "device-width",
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
    viewportFit: "cover",
  },
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en" className={`${inter.variable}`} suppressHydrationWarning>
      <body className="font-sans antialiased min-h-screen bg-background text-foreground" suppressHydrationWarning>
        <PostHogProvider>
          <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
            <UnofficialDomainBanner />
            <Favicon />
            {children}
          </ThemeProvider>
        </PostHogProvider>
      </body>
    </html>
  )
}
