import * as React from "react"
import {
  LayoutDashboardIcon,
  AppWindowIcon,
  PhoneIcon,
  FileTextIcon,
} from "lucide-react"
import { Link } from "@inertiajs/react"

import { NavMain } from "@/components/nav-main"
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"

interface User {
  id: number
  name: string
  email: string
  admin: boolean
}

interface AppSidebarProps extends React.ComponentProps<typeof Sidebar> {
  user: User
}

export function AppSidebar({ user, ...props }: AppSidebarProps) {
  const navMain: Array<{
    title: string
    url: string
    icon: typeof LayoutDashboardIcon
    activePattern?: string
  }> = [
    {
      title: "Dashboard",
      url: "/dashboard",
      icon: LayoutDashboardIcon,
    },
    {
      title: "Call Recordings",
      url: "/call_recordings",
      icon: PhoneIcon,
      activePattern: "/call_recordings",
    },
    {
      title: "Call Scripts",
      url: "/call_scripts",
      icon: FileTextIcon,
      activePattern: "/call_scripts",
    },
  ]

  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild className="hover:bg-transparent active:bg-transparent data-[active=true]:bg-transparent">
              <Link href="/dashboard">
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-black text-white dark:bg-white dark:text-black">
                  <AppWindowIcon className="size-4" />
                </div>
                <div className="grid flex-1 text-left text-sm leading-tight">
                  <span className="truncate font-semibold">Call Center KPI</span>
                </div>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={navMain} />
      </SidebarContent>
    </Sidebar>
  )
}
