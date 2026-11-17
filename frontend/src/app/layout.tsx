import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "GrantFlow",
  description: "Democratic capital allocation for public goods with Sybil-resistant quadratic matching",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-[#090d16] text-[#f8fafc] font-sans antialiased selection:bg-blue-600 selection:text-white">
        <header className="sticky top-0 z-50 border-b border-gray-800 bg-[#090d16]/90 backdrop-blur-md">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <div className="flex items-center gap-8">
              <Link href="/" className="flex items-center gap-2 font-bold text-xl tracking-tight text-white hover:text-blue-400 transition-colors">
                <span className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white font-black text-lg shadow-lg shadow-blue-500/20">
                  G
                </span>
                GrantFlow
              </Link>
              <nav className="hidden md:flex items-center gap-6 text-sm font-medium text-gray-400">
                <Link href="/projects" className="hover:text-white transition-colors">Projects</Link>
                <Link href="/rounds" className="hover:text-white transition-colors">Funding Rounds</Link>
                <Link href="/donate" className="hover:text-white transition-colors">Donate & Match</Link>
                <Link href="/dashboard" className="hover:text-white transition-colors">Dashboard</Link>
              </nav>
            </div>
            <div className="flex items-center gap-3">
              <button className="px-4 py-2 rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-sm font-medium transition-all shadow-lg shadow-blue-600/20">
                Connect Wallet
              </button>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {children}
        </main>

        <footer className="border-t border-gray-800 py-8 text-center text-xs text-gray-500">
          <p>© 2026 GrantFlow Protocol. EVM Optimized • Sybil-Resistant • Merkle-Verified.</p>
        </footer>
      </body>
    </html>
  );
}
