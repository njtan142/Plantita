'use client';

import React, { useState } from 'react';
import {
  ColumnDef,
  ColumnFiltersState,
  SortingState,
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
} from '@tanstack/react-table';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { mediaService } from '@/services/mediaService';
import { Media, MediaStatus } from '@/types/api';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Trash2, Eye, Check, X } from 'lucide-react';
import { toast } from 'sonner';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle } from '@/components/ui/alert-dialog';

const MediaGrid = () => {
  const queryClient = useQueryClient();
  const [sorting, setSorting] = useState<SortingState>([]);
  const [columnFilters, setColumnFilters] = useState<ColumnFiltersState>([]);
  const [rowSelection, setRowSelection] = useState({});
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [mediaToDelete, setMediaToDelete] = useState<Media | null>(null);

  const { data: mediaData, isLoading, isError, error } = useQuery({
    queryKey: ['media'],
    queryFn: () => mediaService.getMedia(),
  });

  const media = mediaData?.data || [];

  const deleteMutation = useMutation({
    mutationFn: (id: string) => mediaService.deleteMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media deleted successfully');
      setDeleteDialogOpen(false);
      setMediaToDelete(null);
    },
    onError: () => {
      toast.error('Failed to delete media');
    },
  });

  const approveMutation = useMutation({
    mutationFn: (id: string) => mediaService.approveMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media approved successfully');
    },
    onError: () => {
      toast.error('Failed to approve media');
    },
  });

  const rejectMutation = useMutation({
    mutationFn: (id: string) => mediaService.rejectMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media rejected successfully');
    },
    onError: () => {
      toast.error('Failed to reject media');
    },
  });

  const handleDelete = (mediaItem: Media) => {
    setMediaToDelete(mediaItem);
    setDeleteDialogOpen(true);
  };

  const confirmDelete = () => {
    if (mediaToDelete) {
      deleteMutation.mutate(mediaToDelete.id);
    }
  };

  const handleApprove = (id: string) => {
    approveMutation.mutate(id);
  };

  const handleReject = (id: string) => {
    rejectMutation.mutate(id);
  };

  const columns: ColumnDef<Media>[] = [
    {
      accessorKey: 'filename',
      header: 'Filename',
      cell: ({ row }) => (
        <div className="font-medium">{row.getValue('filename')}</div>
      ),
    },
    {
      accessorKey: 'mimeType',
      header: 'Type',
      cell: ({ row }) => {
        const mimeType = row.getValue('mimeType') as string;
        const type = mimeType.split('/')[0];
        return <Badge variant="outline">{type}</Badge>;
      },
    },
    {
      accessorKey: 'size',
      header: 'Size',
      cell: ({ row }) => {
        const size = row.getValue('size') as number;
        const formattedSize = size > 1024 * 1024 
          ? `${(size / (1024 * 1024)).toFixed(2)} MB`
          : size > 1024 
          ? `${(size / 1024).toFixed(2)} KB`
          : `${size} B`;
        return <div>{formattedSize}</div>;
      },
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => {
        const status = row.getValue('status') as MediaStatus;
        const statusColors = {
          [MediaStatus.PENDING]: 'bg-yellow-100 text-yellow-800',
          [MediaStatus.APPROVED]: 'bg-green-100 text-green-800',
          [MediaStatus.REJECTED]: 'bg-red-100 text-red-800',
          [MediaStatus.DELETED]: 'bg-gray-100 text-gray-800',
        };
        return (
          <Badge className={statusColors[status]}>
            {status.charAt(0).toUpperCase() + status.slice(1).toLowerCase()}
          </Badge>
        );
      },
    },
    {
      accessorKey: 'uploadedByUser',
      header: 'Uploaded By',
      cell: ({ row }) => {
        const user = row.original.uploadedByUser;
        return user ? `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.username : 'Unknown';
      },
    },
    {
      accessorKey: 'createdAt',
      header: 'Upload Date',
      cell: ({ row }) => {
        const date = new Date(row.getValue('createdAt'));
        return date.toLocaleDateString();
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => {
        const mediaItem = row.original;
        return (
          <div className="flex space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => console.log('Preview', mediaItem.id)}
            >
              <Eye className="h-4 w-4" />
            </Button>
            {mediaItem.status === MediaStatus.PENDING && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleApprove(mediaItem.id)}
                  disabled={approveMutation.isPending}
                >
                  <Check className="h-4 w-4" />
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleReject(mediaItem.id)}
                  disabled={rejectMutation.isPending}
                >
                  <X className="h-4 w-4" />
                </Button>
              </>
            )}
            <Button
              variant="destructive"
              size="sm"
              onClick={() => handleDelete(mediaItem)}
              disabled={deleteMutation.isPending}
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        );
      },
    },
  ];

  const table = useReactTable({
    data: media,
    columns,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onRowSelectionChange: setRowSelection,
    state: {
      sorting,
      columnFilters,
      rowSelection,
    },
  });

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (isError) {
    return <p className="text-red-500">{error.message}</p>;
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold">Media Management</h2>
      </div>
      
      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        <Input
          placeholder="Filter by filename..."
          value={(table.getColumn('filename')?.getFilterValue() as string) ?? ''}
          onChange={(event) =>
            table.getColumn('filename')?.setFilterValue(event.target.value)
          }
          className="max-w-sm"
        />
        <Select
          value={(table.getColumn('status')?.getFilterValue() as string) ?? 'all'}
          onValueChange={(value) => {
            if (value === 'all') {
              table.getColumn('status')?.setFilterValue(undefined);
            } else {
              table.getColumn('status')?.setFilterValue(value);
            }
          }}
        >
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Statuses</SelectItem>
            <SelectItem value={MediaStatus.PENDING}>Pending</SelectItem>
            <SelectItem value={MediaStatus.APPROVED}>Approved</SelectItem>
            <SelectItem value={MediaStatus.REJECTED}>Rejected</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Table */}
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(
                          header.column.columnDef.header,
                          header.getContext()
                        )}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow
                  key={row.id}
                  data-state={row.getIsSelected() && 'selected'}
                >
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center"
                >
                  No results.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex items-center justify-end space-x-2 py-4">
        <div className="flex-1 text-sm text-muted-foreground">
          {table.getFilteredSelectedRowModel().rows.length} of{' '}
          {table.getFilteredRowModel().rows.length} row(s) selected.
        </div>
        <div className="space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
          >
            Previous
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.nextPage()}
            disabled={!table.getCanNextPage()}
          >
            Next
          </Button>
        </div>
      </div>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. This will permanently delete the media file.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={confirmDelete}
              className="bg-destructive hover:bg-destructive/90"
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending ? 'Deleting...' : 'Delete'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
};

export default MediaGrid;
