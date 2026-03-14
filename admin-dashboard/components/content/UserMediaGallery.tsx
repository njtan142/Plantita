'use client';

import { useState, useMemo } from 'react';
import { Media, MediaStatus } from '@/types/api';
import { Card, CardContent } from '@/components/ui/card';
import { Image as ImageIcon } from 'lucide-react';
import { GalleryToolbar } from './user-media-gallery/GalleryToolbar';
import { GalleryItem } from './user-media-gallery/GalleryItem';
import { GalleryPagination } from './user-media-gallery/GalleryPagination';

interface UserMediaGalleryProps {
  userId: string;
  media: Media[];
}

export function UserMediaGallery({ media }: UserMediaGalleryProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<MediaStatus | 'all'>('all');
  const [sortBy, setSortBy] = useState<'newest' | 'oldest' | 'name'>('newest');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 12;

  // Filter and sort media
  const { filteredAndSortedMedia, totalPages, paginatedMedia } = useMemo(() => {
    let result = [...media];
    
    if (searchTerm) {
      const lowerSearchTerm = searchTerm.toLowerCase();
      result = result.filter(item => 
        item.filename.toLowerCase().includes(lowerSearchTerm) ||
        (item.description && item.description.toLowerCase().includes(lowerSearchTerm)) ||
        (item.tags && item.tags.some(tag => tag.toLowerCase().includes(lowerSearchTerm)))
      );
    }
    
    if (statusFilter !== 'all') {
      result = result.filter(item => item.status === statusFilter);
    }
    
    result.sort((a, b) => {
      switch (sortBy) {
        case 'newest':
          return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
        case 'oldest':
          return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        case 'name':
          return a.filename.localeCompare(b.filename);
        default:
          return 0;
      }
    });
    
    const total = Math.ceil(result.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginated = result.slice(startIndex, startIndex + itemsPerPage);
    
    return { filteredAndSortedMedia: result, totalPages: total, paginatedMedia: paginated };
  }, [media, searchTerm, statusFilter, sortBy, currentPage]);

  return (
    <Card>
      <CardContent className="p-6">
        <GalleryToolbar
          searchTerm={searchTerm}
          setSearchTerm={setSearchTerm}
          statusFilter={statusFilter}
          setStatusFilter={setStatusFilter}
          sortBy={sortBy}
          setSortBy={setSortBy}
        />

        {paginatedMedia.length === 0 ? (
          <div className="text-center py-12">
            <ImageIcon className="h-12 w-12 mx-auto text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-1">No media found</h3>
            <p className="text-gray-500">
              {media.length === 0 
                ? "This user hasn't uploaded any media yet." 
                : "Try adjusting your search or filter criteria."}
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 mb-6">
              {paginatedMedia.map((item) => (
                <GalleryItem key={item.id} item={item} />
              ))}
            </div>
            
            <GalleryPagination
              currentPage={currentPage}
              totalPages={totalPages}
              setCurrentPage={setCurrentPage}
              totalResults={filteredAndSortedMedia.length}
              itemsPerPage={itemsPerPage}
            />
          </>
        )}
      </CardContent>
    </Card>
  );
}
