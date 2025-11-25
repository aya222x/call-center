import React, { useState } from 'react'
import { router } from '@inertiajs/react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import * as z from 'zod'
import { UploadIcon, ArrowLeftIcon, CalendarIcon } from 'lucide-react'
import { format } from 'date-fns'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Calendar } from '@/components/ui/calendar'
import { cn } from '@/lib/utils'

interface CallScript {
  id: number
  name: string
  call_type: string
}

interface CallRecordingsNewProps {
  call_scripts: CallScript[]
  errors?: {
    call_script_id?: string[]
    language?: string[]
    call_date?: string[]
    audio_file?: string[]
  }
}

const callRecordingSchema = z.object({
  call_script_id: z.string().min(1, 'Call script is required'),
  language: z.string().min(1, 'Language is required'),
  call_date: z.string().min(1, 'Call date is required'),
  customer_name: z.string().optional(),
  customer_phone: z.string().optional(),
})

type CallRecordingFormData = z.infer<typeof callRecordingSchema>

export default function CallRecordingsNew({ call_scripts, errors }: CallRecordingsNewProps) {
  const {
    register,
    handleSubmit,
    formState: { errors: formErrors, isSubmitting },
    setValue,
    watch,
  } = useForm<CallRecordingFormData>({
    resolver: zodResolver(callRecordingSchema),
    defaultValues: {
      call_date: new Date().toISOString().split('T')[0],
    },
  })

  const [audioFile, setAudioFile] = useState<File | null>(null)
  const [error, setError] = useState('')
  const [callDate, setCallDate] = useState<Date>(new Date())

  const selectedCallScriptId = watch('call_script_id')
  const selectedLanguage = watch('language')

  const handleAudioChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      // Validate file type
      const validTypes = ['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav']
      if (!validTypes.includes(file.type)) {
        setError('Please upload a valid audio file (MP3 or WAV)')
        return
      }

      // Validate file size (max 50MB)
      const maxSize = 50 * 1024 * 1024
      if (file.size > maxSize) {
        setError('Audio file must be less than 50MB')
        return
      }

      setAudioFile(file)
      setError('')
    }
  }

  const onSubmit = (data: CallRecordingFormData) => {
    if (!audioFile) {
      setError('Please select an audio file')
      return
    }

    setError('')

    router.post('/call_recordings', {
      call_recording: {
        call_script_id: data.call_script_id,
        language: data.language,
        call_date: format(callDate, 'yyyy-MM-dd'),
        customer_name: data.customer_name || null,
        customer_phone: data.customer_phone || null,
        audio_file: audioFile,
      },
    }, {
      onError: (errors) => {
        setError(Object.values(errors).flat().join(', ') || 'Upload failed')
      },
    })
  }

  return (
    <div className="flex flex-1 flex-col">
      <div className="@container/main flex flex-1 flex-col gap-2">
        <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6">
          <div className="px-4 lg:px-6">
            {/* Header */}
            <div className="mb-6">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => router.visit('/call_recordings')}
                className="mb-4"
              >
                <ArrowLeftIcon className="mr-2 h-4 w-4" />
                Back to Recordings
              </Button>
              <h1 className="text-2xl font-bold">Upload Call Recording</h1>
              <p className="text-muted-foreground mt-1">
                Upload an audio file to evaluate operator performance
              </p>
            </div>

            <Card>
              <CardHeader>
                <CardTitle>Recording Details</CardTitle>
                <CardDescription>
                  Provide information about the call recording
                </CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                  {error && (
                    <div className="rounded-md bg-destructive/15 p-3 text-sm text-destructive">
                      {error}
                    </div>
                  )}

                  {/* Audio File Upload */}
                  <div className="space-y-2">
                    <Label htmlFor="audio_file">Audio File *</Label>
                    <div className="flex items-center gap-4">
                      <Label htmlFor="audio_file" className="cursor-pointer">
                        <div className="flex items-center gap-2 rounded-md border border-input bg-background px-4 py-2 hover:bg-accent hover:text-accent-foreground">
                          <UploadIcon className="size-4" />
                          <span>{audioFile ? audioFile.name : 'Choose File'}</span>
                        </div>
                        <Input
                          id="audio_file"
                          type="file"
                          accept="audio/mpeg,audio/mp3,audio/wav"
                          onChange={handleAudioChange}
                          className="hidden"
                        />
                      </Label>
                      {audioFile && (
                        <span className="text-sm text-muted-foreground">
                          {(audioFile.size / 1024 / 1024).toFixed(2)} MB
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      MP3 or WAV format. Maximum 50MB.
                    </p>
                    {errors?.audio_file && (
                      <p className="text-sm text-destructive">{errors.audio_file[0]}</p>
                    )}
                  </div>

                  {/* Call Script Selection */}
                  <div className="space-y-2">
                    <Label htmlFor="call_script_id">Call Script *</Label>
                    <Select
                      value={selectedCallScriptId}
                      onValueChange={(value) => setValue('call_script_id', value)}
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="Select a call script" />
                      </SelectTrigger>
                      <SelectContent>
                        {call_scripts.map((script) => (
                          <SelectItem key={script.id} value={script.id.toString()}>
                            {script.name} ({script.call_type})
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {formErrors.call_script_id && (
                      <p className="text-sm text-destructive">
                        {formErrors.call_script_id.message}
                      </p>
                    )}
                    {errors?.call_script_id && (
                      <p className="text-sm text-destructive">{errors.call_script_id[0]}</p>
                    )}
                  </div>

                  {/* Language Selection */}
                  <div className="space-y-2">
                    <Label htmlFor="language">Language *</Label>
                    <Select
                      value={selectedLanguage}
                      onValueChange={(value) => setValue('language', value)}
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="Select language" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="kyrgyz">Kyrgyz</SelectItem>
                        <SelectItem value="russian">Russian</SelectItem>
                        <SelectItem value="english">English</SelectItem>
                      </SelectContent>
                    </Select>
                    {formErrors.language && (
                      <p className="text-sm text-destructive">{formErrors.language.message}</p>
                    )}
                    {errors?.language && (
                      <p className="text-sm text-destructive">{errors.language[0]}</p>
                    )}
                  </div>

                  {/* Call Date */}
                  <div className="space-y-2">
                    <Label htmlFor="call_date">Call Date *</Label>
                    <Popover>
                      <PopoverTrigger asChild>
                        <Button
                          variant="outline"
                          className={cn(
                            'w-full justify-start text-left font-normal',
                            !callDate && 'text-muted-foreground'
                          )}
                        >
                          <CalendarIcon className="mr-2 h-4 w-4" />
                          {callDate ? format(callDate, 'PPP') : <span>Pick a date</span>}
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="w-auto p-0">
                        <Calendar
                          mode="single"
                          selected={callDate}
                          onSelect={(date) => date && setCallDate(date)}
                          disabled={(date) => date > new Date()}
                          initialFocus
                        />
                      </PopoverContent>
                    </Popover>
                    {formErrors.call_date && (
                      <p className="text-sm text-destructive">{formErrors.call_date.message}</p>
                    )}
                    {errors?.call_date && (
                      <p className="text-sm text-destructive">{errors.call_date[0]}</p>
                    )}
                  </div>

                  {/* Customer Information */}
                  <div className="grid gap-4 md:grid-cols-2">
                    <div className="space-y-2">
                      <Label htmlFor="customer_name">Customer Name</Label>
                      <Input
                        id="customer_name"
                        type="text"
                        placeholder="Optional"
                        {...register('customer_name')}
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="customer_phone">Customer Phone</Label>
                      <Input
                        id="customer_phone"
                        type="tel"
                        placeholder="Optional"
                        {...register('customer_phone')}
                      />
                    </div>
                  </div>

                  {/* Form Actions */}
                  <div className="flex justify-end gap-2 pt-4 border-t">
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => router.visit('/call_recordings')}
                      disabled={isSubmitting}
                    >
                      Cancel
                    </Button>
                    <Button type="submit" disabled={isSubmitting || !audioFile}>
                      {isSubmitting ? 'Uploading...' : 'Upload Recording'}
                    </Button>
                  </div>
                </form>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}
