import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "StoreOps Secure",
  description: "Authenticated store operations, daily POS storage and planning.",
  icons: {
    icon: "/favicon.svg",
    shortcut: "/favicon.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
