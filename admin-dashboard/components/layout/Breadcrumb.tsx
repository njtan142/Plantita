'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { ChevronRight, Home } from 'lucide-react';
import { cn } from '@/lib/utils';

interface BreadcrumbItem {
  name: string;
  href: string;
  icon?: React.ComponentType<{ className?: string }>;
}

const navigationItems: BreadcrumbItem[] = [
  { name: 'Dashboard', href: '/dashboard', icon: Home },
  { name: 'Users', href: '/dashboard/users' },
  { name: 'Media', href: '/dashboard/media' },
  { name: 'Analytics', href: '/dashboard/analytics' },
  { name: 'Settings', href: '/dashboard/settings' }
];

export function Breadcrumb() {
  const pathname = usePathname();

  // Generate breadcrumb items based on current path
  const getBreadcrumbs = (): BreadcrumbItem[] => {
    const breadcrumbs: BreadcrumbItem[] = [{ name: 'Dashboard', href: '/dashboard', icon: Home }];

    if (pathname === '/dashboard') {
      return breadcrumbs;
    }

    // Find matching navigation item
    const currentItem = navigationItems.find(item =>
      item.href !== '/dashboard' && pathname.startsWith(item.href)
    );

    if (currentItem) {
      breadcrumbs.push({
        name: currentItem.name,
        href: currentItem.href,
        icon: currentItem.icon
      });

      // Add sub-paths if any
      const subPath = pathname.replace(currentItem.href, '');
      if (subPath && subPath !== '/') {
        const subPaths = subPath.split('/').filter(Boolean);
        let currentPath = currentItem.href;

        subPaths.forEach((pathSegment) => {
          currentPath += `/${pathSegment}`;
          breadcrumbs.push({
            name: pathSegment.charAt(0).toUpperCase() + pathSegment.slice(1),
            href: currentPath
          });
        });
      }
    }

    return breadcrumbs;
  };

  const breadcrumbs = getBreadcrumbs();

  return (
    <nav className="flex items-center space-x-1 text-sm text-gray-600">
      {breadcrumbs.map((item, index) => (
        <div key={item.href} className="flex items-center">
          {index > 0 && (
            <ChevronRight className="h-4 w-4 mx-1 text-gray-400" />
          )}

          {index === breadcrumbs.length - 1 ? (
            // Last item (current page) - not clickable
            <span className="font-medium text-gray-900 flex items-center">
              {item.icon && <item.icon className="h-4 w-4 mr-1" />}
              {item.name}
            </span>
          ) : (
            // Previous items - clickable
            <Link
              href={item.href}
              className={cn(
                'flex items-center hover:text-gray-900 transition-colors',
                index === 0 ? 'hover:text-blue-600' : ''
              )}
            >
              {item.icon && <item.icon className="h-4 w-4 mr-1" />}
              {item.name}
            </Link>
          )}
        </div>
      ))}
    </nav>
  );
}