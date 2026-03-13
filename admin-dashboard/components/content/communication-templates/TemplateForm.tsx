'use client';

import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Button } from '@/components/ui/button';
import { Trash2 } from 'lucide-react';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';

interface TemplateFormProps {
  name: string;
  setName: (name: string) => void;
  subject: string;
  setSubject: (subject: string) => void;
  body: string;
  setBody: (body: string) => void;
  type: 'email' | 'notification';
  setType: (type: 'email' | 'notification') => void;
  variables: string[];
  onAddVariable: () => void;
  onRemoveVariable: (index: number) => void;
  onVariableChange: (index: number, value: string) => void;
  idPrefix?: string;
}

export function TemplateForm({
  name,
  setName,
  subject,
  setSubject,
  body,
  setBody,
  type,
  setType,
  variables,
  onAddVariable,
  onRemoveVariable,
  onVariableChange,
  idPrefix = 'template'
}: TemplateFormProps) {
  return (
    <div className="space-y-4 max-h-[60vh] overflow-y-auto pr-2">
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-name`}>Template Name</Label>
        <Input
          id={`${idPrefix}-name`}
          placeholder="Enter template name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
      </div>
      
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-subject`}>Subject</Label>
        <Input
          id={`${idPrefix}-subject`}
          placeholder="Enter subject line"
          value={subject}
          onChange={(e) => setSubject(e.target.value)}
        />
      </div>
      
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-type`}>Template Type</Label>
        <Select value={type} onValueChange={(value) => setType(value as 'email' | 'notification')}>
          <SelectTrigger id={`${idPrefix}-type`}>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="email">Email</SelectItem>
            <SelectItem value="notification">In-App Notification</SelectItem>
          </SelectContent>
        </Select>
      </div>
      
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-body`}>Body</Label>
        <Textarea
          id={`${idPrefix}-body`}
          placeholder="Enter template body. Use {{variable}} to insert variables."
          value={body}
          onChange={(e) => setBody(e.target.value)}
          rows={6}
        />
      </div>
      
      <div className="space-y-2">
        <div className="flex justify-between items-center">
          <Label>Variables</Label>
          <Button variant="outline" size="sm" onClick={onAddVariable}>
            Add Variable
          </Button>
        </div>
        <div className="space-y-2">
          {variables.map((variable, index) => (
            <div key={index} className="flex gap-2">
              <Input
                placeholder="Variable name (e.g., username)"
                value={variable}
                onChange={(e) => onVariableChange(index, e.target.value)}
              />
              <Button 
                variant="outline" 
                size="icon"
                onClick={() => onRemoveVariable(index)}
                disabled={variables.length === 1}
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            </div>
          ))}
          {variables.length === 0 && (
            <p className="text-sm text-muted-foreground">No variables added</p>
          )}
        </div>
      </div>
    </div>
  );
}
