'use client';

import React from 'react';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { MediaStatus } from '@/types/api';
import { Filter, Search } from 'lucide-react';

interface GalleryToolbarProps {
  searchTerm: string;
  setSearchTerm: (value: string) => void;
  statusFilter: MediaStatus | 'all';
  setStatusFilter: (value: MediaStatus | 'all') => void;
  sortBy: 'newest' | 'oldest' | 'name';
  setSortBy: (value: 'newest' | 'oldest' | 'name') => void;
}

export const GalleryToolbar = ({
  searchTerm,
  setSearchTerm,
  statusFilter,
  setStatusFilter,
  sortBy,
  setSortBy,
}: GalleryToolbarProps) => {
  return (
    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
      <div className="flex-1">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <Input
            placeholder="Search media..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>
      
      <div className="flex flex-wrap gap-2">
        <div className="flex items-center space-x-2">
          <Filter className="h-4 w-4 text-gray-500" />
          <Select value={statusFilter} onValueChange={(value: MediaStatus | 'all') => setStatusFilter(value)}>
            <SelectTrigger className="w-[120px]">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value={MediaStatus.APPROVED}>Approved</SelectItem>
              <SelectItem value={MediaStatus.PENDING}>Pending</SelectItem>
              <SelectItem value={MediaStatus.REJECTED}>Rejected</SelectItem>
              <SelectItem value={MediaStatus.DELETED}>Deleted</SelectItem>
            </SelectContent>
          </Select>
        </div>
        
        <Select value={sortBy} onValueChange={(value: 'newest' | 'oldest' | 'name') => setSortBy(value)}>
          <SelectTrigger className="w-[120px]">
            <SelectValue placeholder="Sort by" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="newest">Newest</SelectItem>
            <SelectItem value="oldest">Oldest</SelectItem>
            <SelectItem value="name">Name</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  );
};
